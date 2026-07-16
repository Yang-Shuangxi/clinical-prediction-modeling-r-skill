# 验证、性能与临床效用

## 校准

校准回答“预测风险是否与观察风险一致”。二分类模型报告校准曲线，并尽可能报告校准截距和斜率；生存/竞争风险模型在每个临床相关的预设时间点报告校准。开发数据上的曲线是表观校准，不是验证。

教材使用的主要路径：

```r
# 二分类或 Cox 的 Bootstrap 乐观校正校准。
cal <- rms::calibrate(fit, method = "boot", B = 1000)
plot(cal)

# 生存或竞争风险模型在指定时间点的评价与比较。
score <- riskRegression::Score(
  object = list("model" = fit),
  formula = survival::Surv(TIME, EVENT) ~ 1,
  times = c(365, 1095),
  metrics = c("auc", "brier"),
  plots = c("calibration", "ROC"),
  data = validation_data
)
```

对于竞争风险，使用 `prodlim::Hist()` 公式并设置 `cause`。不要将同一开发数据的分位数组-观察风险图作为外部校准。

## 判别与整体误差

- 二分类：AUC/C-index 与 95% CI；使用 `pROC::roc()` 时确认输入为事件风险，且正类方向正确。
- 生存：在每个时间点报告时间依赖 AUC；可用 `timeROC` 或 `riskRegression::Score()`，并写明删失加权方式。
- Cox：报告 Harrell C-index 以及其不确定性，但不要以它替代固定时间校准；`summary(coxph_fit)$concordance` 是快速诊断而非完整验证。
- 整体误差：补充 Brier score/预测误差曲线，特别是在有删失情形。

模型比较应在相同的验证预测上进行，配对处理。报告比较的完整模型、简约模型、时间点及置信区间；不根据开发集 AUC 的微小差异宣称优越。

使用多重插补时，先按患者合并同一外层 assessment 的多份风险预测（通常取预先规定的平均风险），再在合并的 OOF 预测上计算 AUC/PR-AUC、Brier、log loss、校准截距/斜率和 DCA；不要把各插补数据集的 AUC 简单平均，也不要直接把 Rubin 规则套在 AUC 上。模型比较使用同一患者/中心重抽样的配对差值 CI；5 个折的均值 ± SD 不是 95% CI。仅对已固定 OOF 预测做 Bootstrap 只反映评估样本的不确定性；若要反映训练、插补和调参不确定性，应在 Bootstrap 内重做完整的嵌套流程，并在报告中说明。

## 内部与外部验证

**内部验证：** 对全部建模流水线作 Bootstrap 或重复/嵌套 CV。`rms::validate(fit, method = "boot", B = 1000, dxy = TRUE)` 适合可由 `rms` 重拟合的预先定义模型；若模型中包含插补、筛选或调参，重抽样函数必须重做这些步骤。教材中 `caret::train()` 的 LGOCV、10 折、LOOCV 和 Bootstrap 是教学演示；一次 LGOCV/随机留出不应作为最终依据。

**外部验证：** 选择尽量不同于开发队列的时间、中心、地域或测量流程。保持模型公式与系数固定，先验证不更新的性能；若更新，清晰区分再校准、模型修订和重新开发。

## DCA

```r
# 二分类，PREDICTED_RISK 必须来自相应模型或验证预测。
dca_result <- dcurves::dca(
  EVENT ~ PREDICTED_RISK,
  data = validation_data
)
plot(dca_result, smooth = TRUE)

# 生存资料：时间单位必须与 TIME_POINT 一致。
dca_surv <- dcurves::dca(
  survival::Surv(FOLLOW_UP, EVENT) ~ PREDICTED_RISK,
  time = TIME_POINT,
  data = validation_data
)
```

只在临床可解释的阈值范围内显示净获益，报告阈值对应的行动（治疗、检查、转诊）和假阳性/假阴性的相对权重。不要用平滑曲线掩盖数据稀疏或不确定性。

## NRI 与 IDI

教材演示 `nricens`、`PredictABEL` 与 `survIDINRI`。将它们作为补充：风险类别须在分析前依据临床行动制定；报告重分类表、事件/非事件组成、置信区间、时间点和删失处理。避免连续 NRI 的二元“改善/未改善”结论。先报告校准、判别和净获益。

## 报告与偏倚检查

使用 [TRIPOD+AI](https://www.equator-network.org/reporting-guidelines/tripod-statement/) 核对模型开发、验证或更新的透明报告；该指南覆盖回归和机器学习临床预测模型。使用 [PROBAST](https://www.probast.org/) 审计参与者、预测因子、结局和分析四个偏倚/适用性领域。将检查结果写入限制部分，而不是仅附上清单。
