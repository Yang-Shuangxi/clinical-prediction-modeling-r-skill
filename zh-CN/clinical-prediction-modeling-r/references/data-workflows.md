# 临床数据契约、导入与整理

在拟合任何模型之前，先确定每张表的观察单位、主键、时间含义和用途。此文件处理“数据是否可用于建模”的问题；缺失值、泄漏和验证边界另见 [workflow.md](workflow.md)。

## 目录

- [1. 写下数据契约](#1-写下数据契约)
- [2. 导入时固定关键类型](#2-导入时固定关键类型)
- [3. 表关系、纵向资料与安全连接](#3-表关系纵向资料与安全连接)
- [4. 日期、时间与预测时点](#4-日期时间与预测时点)
- [5. 固定窗口结局与随访完整性](#5-固定窗口结局与随访完整性)
- [6. 分类、连续值、缺失和异常的数据质量审计](#6-分类连续值缺失和异常的数据质量审计)
- [7. 建模前闸门](#7-建模前闸门)

## 1. 写下数据契约

每个输入表至少记录：文件版本/日期、行对应的实体（患者、就诊、检查、样本或中心）、主键、外键、每个变量的来源/单位/允许值/缺失编码、测量时间和可进入预测模型的最早时点。分析表也必须指定“一行代表什么”。

基线固定窗口预测模型通常是一行一名受试者；生存模型可是一行一名受试者或一段 start-stop 随访区间；重复就诊或化验表本身不能直接当作基线分析表。不要根据“恰好能唯一”的若干列猜测主键；键必须有领域含义。

推荐的最小目录结构：

```text
project/
  data/raw/              # 原始文件：只读，不用 R 覆盖
  data/derived/          # 脚本生成的中间/分析数据
  data-dictionary/       # 字段、编码、单位、时间和版本
  scripts/               # 01_import.R, 02_derive.R, 03_model.R, ...
  reports/               # .Rmd 或 .qmd 源文件
  outputs/               # 图、表、模型对象、审计清单
  renv.lock
```

从项目根目录以相对路径运行；不要在交付脚本中使用个人电脑的绝对路径、`setwd()` 或保存/恢复 `.RData` 来传递状态。

## 2. 导入时固定关键类型

先在探索副本中检查列名、表头、缺失编码和日期表示；再把关键分析字段的类型固化到脚本。不要把患者 ID 导入为数值（前导零会丢失），也不要让日期、二元结局或分类编码完全依赖猜测。

```r
source("scripts/clinical_model_checks.R")
source("scripts/data_contract_checks.R")

baseline_raw <- readr::read_csv(
  "data/raw/baseline.csv",
  na = c("", "NA", "N/A", ".", "Unknown"),
  locale = readr::locale(encoding = "UTF-8", tz = "Asia/Shanghai"),
  name_repair = "check_unique",
  col_types = readr::cols(
    patient_id = readr::col_character(),
    index_date = readr::col_date(format = "%Y-%m-%d"),
    age_years = readr::col_double(),
    sex = readr::col_character(),
    outcome_1y = readr::col_integer(),
    .default = readr::col_skip()
  )
)
readr::stop_for_problems(baseline_raw)
cp_assert_unique_key(baseline_raw, "patient_id")
cp_check_allowed_values(baseline_raw, "outcome_1y", c(0, 1), allow_na = FALSE)
```

`col_skip()` 的例子有意只载入经数据字典批准的字段；若需要保留全部字段，应为所有将用于分析或审核的字段给出类型，随后保存实际 schema 与解析问题。对于 CSV，`readr::problems()` 可以提取失败位置；自动管线应在未解释的解析失败处停止。

对于 Excel，先确认工作表、表头范围和 Excel 日期而非只读取“看起来像数据”的区域。`readxl` 按单元格类型猜测，数值日期及混入的文字可能造成无声的类型改变：

```r
baseline_xlsx <- readxl::read_excel(
  "data/raw/baseline.xlsx",
  sheet = "Baseline",
  range = "A3:G10000",
  na = c("", "NA", "Unknown"),
  col_types = c("text", "date", "numeric", "text", "numeric", "numeric", "numeric"),
  .name_repair = "check_unique"
)
```

导入后保存一份不可识别化的字段概览与审计结果，而不是只相信控制台打印：

```r
cp_data_profile(baseline_raw)
cp_missingness(baseline_raw)
```

## 3. 表关系、纵向资料与安全连接

连接前先运行键审计，并将预期基数写进代码。`relationship` 的方向以 `left_join(x, y, ...)` 的 `x`、`y` 为准：一对多表示 `x` 的一条记录可对应 `y` 的多条记录；多对一表示 `y` 每个键唯一。多对多会产生笛卡儿扩张，只有设计上确有此含义时才可显式允许。

```r
cp_assert_unique_key(baseline_raw, "patient_id")

# 将每位患者的纵向化验预先按临床定义的 time zero 聚合为一行。
labs_at_index <- labs_raw |>
  dplyr::filter(
    !is.na(assay_time),
    assay_time <= index_time,
    assay_time >= index_time - lubridate::days(30)
  ) |>
  dplyr::group_by(patient_id) |>
  dplyr::slice_max(assay_time, n = 1, with_ties = FALSE) |>
  dplyr::ungroup()

join_audit <- cp_check_join_keys(
  baseline_raw, labs_at_index,
  by = "patient_id",
  relationship = "one-to-one"
)
stopifnot(join_audit$unmatched_x == 0L)  # 仅在每人必须有化验时使用

analysis_base <- dplyr::left_join(
  baseline_raw, labs_at_index,
  by = "patient_id",
  relationship = "one-to-one"
)
stopifnot(nrow(analysis_base) == nrow(baseline_raw))
```

对于预期一对多的链接，先聚合到分析单位；若研究确实是重复测量/动态预测，改为显式定义 start-stop、landmark 或层级模型数据结构，而不是让连接隐式重复患者。用 `anti_join()` 或 `cp_check_join_keys()` 检查未匹配的左右键，并在报告中说明它们是数据错误、真实缺失、纳排标准还是允许存在的记录。

不要依赖同名列的自然连接。始终指定 `by`；名称不同的键使用明确映射，例如 `by = c("patient_id" = "subject_id")`。连接后核对行数、分析单位、重复 ID、关键变量缺失和衍生变量的单位。

## 4. 日期、时间与预测时点

把日期（无时刻）与日期时间（一个瞬时）区分开。只需要日时使用 `Date`；需要排序、窗口或跨中心时刻时使用带 IANA 时区的 `POSIXct`，如 `"Asia/Shanghai"` 或 `"UTC"`。`with_tz()` 只改变同一瞬时的显示时区，`force_tz()` 会重解释钟表时间；后者仅适合已知来源时区被错误标记的资料。

```r
events <- events |>
  dplyr::mutate(
    index_time = lubridate::ymd_hms(index_time, tz = "Asia/Shanghai"),
    measurement_time = lubridate::ymd_hms(measurement_time, tz = "Asia/Shanghai")
  )

time_audit <- cp_check_time_order(
  events,
  earlier = "measurement_time",
  later = "index_time",
  id = "patient_id",
  allow_equal = TRUE
)
stopifnot(time_audit$violations == 0L)
```

在生存或竞争风险资料中，单独审计 time zero、入组/左截断、事件日期、最后随访、删失及每种竞争事件。不能以在预测时点后才知晓的诊断、治疗、检查结果或未来随访作为基线预测因子。

## 5. 固定窗口结局与随访完整性

不要把“没有记录事件”自动编码为 `0`。先明确固定窗口是日历年还是从 time zero 起的 365 天，并明确事件窗口（例如 `(time zero, time zero + horizon]`）、time zero 前的既往事件和允许的删失规则。time zero 前已发生的目标事件通常是既往病例，应排除或另建复发模型；在窗口结束前失访且未发生事件者不能无条件作为非事件。

```r
# 仅示意：event_1y 的规则须由方案预先定义。
outcome_1y <- outcome_raw |>
  dplyr::left_join(
    baseline_raw |> dplyr::select(patient_id, index_time),
    by = "patient_id",
    relationship = "many-to-one"
  ) |>
  dplyr::mutate(
    horizon_end = index_time + lubridate::days(365),
    event_in_window = event_code == 1L &
      event_time > index_time & event_time <= horizon_end,
    complete_followup = last_followup_time >= horizon_end
  )
```

在汇总为一行/患者前，检查同一患者的多条结局记录、重复事件和竞争事件；为目标事件选择最早符合窗口的记录，并保存排除/不完整随访原因。只有通过结局编码、时间窗口和随访完整性审计的记录才进入二分类模型。

## 6. 分类、连续值、缺失和异常的数据质量审计

在转换为 factor 前先验证允许水平，并固定参考组；不要以 `1`、`2`、`3` 之类整数暗示无序类别存在等距关系。

```r
cp_check_allowed_values(analysis_base, "sex", c("female", "male"), allow_na = TRUE)
analysis_base$sex <- stats::relevel(
  factor(analysis_base$sex, levels = c("female", "male")),
  ref = "female"
)
```

用分布图、散点图、分层计数、缺失模式和单位范围发现录入/单位错误、罕见组和不可能值。异常值不是自动删除理由：核对来源；若确证无效，使用预先记录的规则改为缺失或修正；若保留，展示稳健性分析。不要用全数据的结局信息寻找“最佳”转换、截点或异常值规则。

缺失编码（如 `999`、`"unknown"`、空字符串）应在导入或最早可审计步骤统一为 `NA`，同时保留原始值/规则说明。后续插补、缩放、变量筛选和特征生成仍必须限制在训练集及每个重抽样中。

## 7. 建模前闸门

只有在以下问题都有可审计答案时，才进入模型脚本：

1. 原始输入、表头、字段类型、单位与缺失码是否可重现？
2. 主键是否无缺失且按声明唯一？是否解释了未匹配与所有一对多关系？
3. 分析表的一行是什么？连接/聚合后是否仍然如此？
4. 每个候选预测因子是否在预测时点可得？日期、时区和随访顺序是否合理？
5. 结局及其编码是否已由临床/领域专家审核？

通过闸门不代表资料不存在偏倚；它只防止常见的导入、连接、时间和分析单位错误污染后续模型。
