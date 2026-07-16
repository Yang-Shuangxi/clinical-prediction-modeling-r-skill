---
name: clinical-prediction-modeling-r
description: Construct, validate, and report reproducible clinical disease-risk prediction models in R. Use for Chinese or English requests involving 医学/临床风险预测模型, clinical data import or wrangling, data dictionaries, safe table joins, diagnostic or prognostic models, linear/Logistic/Cox/competing-risk models, LASSO, random forests, nomograms, calibration, ROC/AUC/C-index, DCA, resampling, external validation, or R Markdown/Quarto model reports.
---

# R 临床预测模型

## 目标与边界

构建可复现的研究级预测模型，而非直接给出个体诊疗建议或部署临床决策规则。将模型的预期用途、预测时点、目标人群、可用预测因子和验证策略置于代码之前。若结局定义、时间零点、目标事件或预测时点不清楚，先询问；不要用默认值代替。

将当前 R 与包版本写入交付物。不要把开发集表观性能作为最终性能，不要声称模型可临床使用，除非已有相应的独立验证、临床效用评估和所需治理/审批证据。

## 先建立分析协议

在建模前，用简洁表格确认以下项目：

| 项目 | 必须明确的内容 |
| --- | --- |
| 研究问题 | 诊断或预后；拟支持的临床决策 |
| 人群 | 纳排标准、中心/时间范围、分析单位、数据泄漏风险 |
| 结局 | 结局代码、判定方法、盲法/可得性、预测窗口 |
| 时间轴 | time zero、随访单位、删失定义、竞争事件编码 |
| 预测因子 | 预测时点是否可得、原始单位、缺失、预处理和临床理由 |
| 开发与验证 | 时间/地域外部验证优先；否则重抽样内部验证 |
| 性能与效用 | 校准、判别、整体误差、临床阈值和比较方案 |

载入 [workflow.md](references/workflow.md) 以确定数据准备、缺失值、样本量和避免泄漏的规则。对小样本、稀有结局、多中心资料、缺失数据、机器学习或模型更新，先读取该文件再写模型代码。

## 数据契约与可复现工作流

当原始资料来自 EHR、登记库、CSV、Excel、多个工作表或纵向多表时，先读取 [data-workflows.md](references/data-workflows.md)，再定义模型。该文件给出导入类型、数据字典、主键/外键、连接基数、日期时间、异常值和分析单位的审计模式。

1. 把原始文件视为只读证据；将清洗、派生变量和分析数据写成独立、可运行的步骤。分析数据必须是一行对应一个预先声明的分析单位。
2. 对 ID、结局、预测时点、日期/时区、单位、允许取值和缺失编码建立数据字典。对导入的 CSV/Excel 显式指定关键列类型，并将任何解析失败、重复主键、非预期取值或时间顺序异常作为待解释问题，而非静默修复。
3. 每次合并前声明两表键和预期关系（一对一、一对多或多对一），并检查未匹配记录。未经明确的纵向聚合，不能将一对多检查、用药或实验室记录直接连接到一行/患者的基线建模表；这样会改变分析单位并重复受试者。
4. 对预测时点建立为 `time zero`；所有基线预测因子须在该时点或临床上可接受的预设窗口内得到。日期时间保留来源时区，区分“改变显示时区”和“纠正错误时区”。
5. 探索性图形、缺失模式和数据质量审计用于发现错误与了解数据，但不可借助完整数据中的结局驱动筛选、截点、标准化、插补或异常值规则后再声称验证独立。所有需估计的预处理仍须在训练/重抽样内完成。

需要将脚本、包版本、输入文件、随机性和报告固化为可重跑交付物时，读取 [reproducible-reporting.md](references/reproducible-reporting.md)。

## 选择结局对应的模型

| 结局和目标 | 首选 R 路径 | 进一步阅读 |
| --- | --- | --- |
| 连续结局 | `stats::lm()`；检查线性、残差和异方差 | [modeling-patterns.md](references/modeling-patterns.md) |
| 固定窗口二分类风险 | `rms::lrm()` 或 `stats::glm(..., family=binomial)` | [modeling-patterns.md](references/modeling-patterns.md) |
| 无序多分类 / 有序结局 | `nnet::multinom()` / `MASS::polr()`；先确认比例优势假设是否合适 | [modeling-patterns.md](references/modeling-patterns.md) |
| 匹配病例对照 | `survival::clogit()`，并保留匹配层 | [modeling-patterns.md](references/modeling-patterns.md) |
| 单一事件的生存风险 | `survival::coxph()` 或 `rms::cph()`；在预设时点给出绝对风险/生存概率 | [cox-and-competing-risks.md](references/cox-and-competing-risks.md) |
| 存在竞争事件的绝对风险 | 以累计发生概率（CIF）为目标；用 `riskRegression::FGR()` 或 `CSC()` | [cox-and-competing-risks.md](references/cox-and-competing-risks.md) |

不要因为有生存资料就默认使用 Cox；不要因为存在竞争事件就把竞争事件当普通删失。以需要预测的量（生存概率、原因特异风险或 CIF）决定模型。

## 通用实施规则

1. 保留连续变量的连续形式；用预设的受限立方样条探索非线性。除非存在临床上预先规定的阈值，不按数据驱动的 cut-off 二分化。
2. 依据临床知识、时间可得性与预测目标预设候选预测因子。不要将单因素筛选、逐步回归、最优子集或随机森林重要性作为唯一的变量选择依据；如确实使用，必须嵌套在重抽样中并报告不稳定性。
3. 对缺失数据说明机制假设。若采用多重插补，将插补、变量选择、标准化和调参限制在每一个训练/重抽样循环内；不要先对全数据处理再做验证。
4. 对 LASSO、随机森林或其他调参模型使用嵌套交叉验证或 Bootstrap；固定随机种子，并保留调参网格、预处理和全部性能估计。
5. 先调用 `scripts/data_contract_checks.R` 与 `scripts/clinical_model_checks.R` 检查导入表、键、时间顺序、关键列、结局编码、随访时间、事件数和公式变量。这些脚本只做结构检查，不替代研究者的临床审核。
6. 显式保存分析数据字典、模型公式、因子参考水平、插补规则、随机种子、包版本和最终对象；不要依赖工作目录中的隐式对象。

在编写模型代码前读取 [modeling-patterns.md](references/modeling-patterns.md)。该文件将教材中线性、Logistic、Cox、竞争风险、LASSO、随机森林和列线图的实现整理为可修改的模式，并明确需要替换的占位内容。

## Cox 与竞争风险附加检查

对每个 Cox 模型：

1. 明确 `Surv(time, event)` 中 `event=1` 的含义，并核对 time zero、时间单位、左截断和删失。
2. 检查比例风险假设（例如 `cox.zph()` 和图形），以及连续预测因子的函数形式。若违背，考虑分层、时间交互或替代模型，并报告处理方式。
3. 将线性预测值转换为预设时点的绝对风险或生存概率；HR 本身不是个体风险预测。
4. 发生竞争事件时同时报告事件编码、目标 cause、CIF 与所选风险模型。不要把 Fine-Gray 的 sHR 当作 Cox HR，也不要将原因特异 HR 与绝对 CIF 混用。

需要 Cox、Fine-Gray、CIF、时间依赖 AUC/校准或竞争风险列线图时，读取 [cox-and-competing-risks.md](references/cox-and-competing-risks.md)。

## 评价、比较与验证

评价与验证必须作用于未用于拟合、调参或特征选择的预测，或使用能校正全过程乐观偏倚的重抽样。

1. **校准：** 报告校准曲线、校准截距与斜率；对生存和竞争风险模型在每个预设时间点评价校准。Brier score 可补充整体误差。
2. **判别：** 二分类使用 AUC/C-index；生存与竞争风险使用时间依赖 AUC/C-index，并给出时间点和删失处理。
3. **临床效用：** 仅在临床可辩护的阈值范围内绘制 DCA；明确结局风险定义、时间点和 treat-all/treat-none 基准。
4. **模型比较：** 在同一验证样本上比较完整与简约模型；NRI/IDI 仅为补充探索性指标，使用预先定义且临床合理的风险类别并给出不确定性，不能单独作为“改进”的结论。
5. **验证：** 优先地域、时间或独立队列外部验证。没有外部数据时，用 Bootstrap 或重复/嵌套交叉验证报告乐观校正性能；不要把一次随机 7:3 切分当作充分验证。

读取 [validation-and-performance.md](references/validation-and-performance.md) 以获取与教材代码对应的 `rms`、`riskRegression`、`pROC`、`pec`、`dcurves` 和 resampling 模式，以及各指标的限制。

## 交付要求

交付结果时依次提供：

1. 分析协议、数据字典、导入/键/时序审计结果和明确的分析单位；
2. 可从干净 R 会话运行的项目脚本或 R Markdown/Quarto，包含包安装说明而非运行时 `install.packages()`；
3. 版本锁定、输入文件版本/校验和、随机种子和 `sessionInfo()`；
4. 最终模型公式、系数/效应量和个体风险计算方式；
5. 校准、判别、整体误差、DCA 与内/外部验证结果及 95% CI；
6. 假设诊断、缺失数据处理、限制、适用人群和不可用于何处；
7. 面向论文的 TRIPOD+AI 报告核对项及 PROBAST 风险偏倚自查。

使用 [source-scope.md](references/source-scope.md) 了解本 skill 蒸馏的教材章节与脚本范围。它不是逐行复制的代码库；针对具体包的当前参数先查阅本地安装版本的帮助页或 CRAN 文档。
