# 蒸馏范围、教材溯源与版本校正

本 skill 基于用户提供的《R语言临床预测模型实战》扫描教材（彭献镇，2022）及 `代码及数据整理-20240929-修订` 配套材料蒸馏。原始教材和代码未复制到本 skill。

| 教材/代码范围 | 本 skill 中的用途 |
| --- | --- |
| 第 2 章与 `02线性回归.R` | 连续结局、相关性、残差、异方差和共线性诊断 |
| 第 3 章与 `03Logistic回归.R` | 二分类、多分类、有序和条件 Logistic 回归、OR/CI |
| 第 4 章与 `04生存资料分析.R` | Kaplan-Meier、log-rank、Cox 与 PH 诊断 |
| 第 5 章与 `05竞争风险模型.R` | CIF、Gray 检验、Fine-Gray `crr()` |
| 第 6 章与 `06自变量筛选.R` | 单因素、逐步、LASSO、随机森林、最优子集、PCA；本 skill 增加了防止选择偏倚的限制 |
| 第 7-13 章与相应脚本 | 列线图、校准、C 指数、ROC、DCA、NRI/IDI、交叉验证与 Bootstrap |

本次更新额外蒸馏用户提供的《R 数据科学》（Hadley Wickham、Garrett Grolemund，中文版，人民邮电出版社，2018；原书 *R for Data Science*, 2017）。未复制原书正文、图表或完整代码；只将下列可迁移的工作流原则改写为临床预测建模中的可执行规则。

| 《R 数据科学》章节 | 融入本 skill 的临床建模用途 |
| --- | --- |
| 第 1 章 | 用分层图形做数据质量、分布、残差、校准和临床效用的可视化审计 |
| 第 2-6 章 | 清晰脚本、探索性数据质量审计、以项目目录和相对路径运行，不依赖 `.RData` 工作区 |
| 第 7-9 章 | tibble 数据框、带类型的数据导入、主键/外键、连接基数、`anti_join()` 排查未匹配记录 |
| 第 10 章 | 用字符串/正则表达式清理编码、空白、单位和半结构化字段，并保留转换规则 |
| 第 11-13 章 | 分类变量有效水平和参考组、日期时间/时区、可读的线性数据处理流水线 |
| 第 14-16 章 | 将重复检查函数化；对批量拟合保留输入、结果与失败信息，而不是复制粘贴代码 |
| 第 17-19 章 | 预测与残差诊断、公式/模型矩阵意识、`broom::tidy()` / `glance()` / `augment()` 整理模型结果 |
| 第 20-23 章 | 以 R Markdown 或 Quarto 将文字、代码、结果和图形编织为可重跑的研究报告；把分析式笔记本当作实验记录 |

该教材对应 2017 年 R 包生态。为避免把旧教学语法或默认行为当成当前最佳实践，新增资料中的当前 API 行为以下列官方文档为准：

- [readr 列类型与解析问题](https://readr.tidyverse.org/articles/column-types.html)、[problems()/stop_for_problems()](https://readr.tidyverse.org/reference/problems.html)：对分析关键列显式声明类型，并让自动脚本在解析异常时失败；
- [readxl 列类型](https://readxl.tidyverse.org/articles/cell-and-column-types.html)：Excel 单元格日期、缺失编码和标题行须显式审计；
- [dplyr mutating joins](https://dplyr.tidyverse.org/reference/mutate-joins.html)：通过 `relationship` 显式确认键关系，警惕多对多笛卡儿扩张；
- [tidymodels recipes 与重抽样](https://rsample.tidymodels.org/articles/Applications/Recipes_and_rsample.html)：含估计参数的预处理必须包含在重抽样内；
- [renv 项目环境](https://rstudio.github.io/renv/)：用 `renv.lock` 记录可恢复的 R 包版本。

采用该教材的 R 实现模式时，优先使用当前安装包的帮助页确认参数和返回对象。对当前方法学边界，本 skill 还以以下一手权威资源为准：

- [TRIPOD+AI（EQUATOR）](https://www.equator-network.org/reporting-guidelines/tripod-statement/)：临床预测模型（回归及机器学习）的报告框架；
- [PROBAST](https://www.probast.org/)：预测模型研究的风险偏倚与适用性评价；
- [TRIPOD 2015 说明](https://www.equator-network.org/2015/01/06/tripod/)：传统预测模型研究透明报告的背景与清单；
- [PROBAST Explanation and Elaboration](https://www.probast.org/wp-content/uploads/2020/02/aime201901010-m181377.pdf)：四个领域和信号问题的解释。

本 skill 的质量控制规则优先于教材中的教学快捷写法：不默认完整病例删除、不以单因素/逐步/最优子集作为主建模路径、不用开发集表观性能作为最终结果，并要求对 Cox、竞争风险和临床效用作目标一致的评价。
