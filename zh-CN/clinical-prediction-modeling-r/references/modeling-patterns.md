# R 建模模式

以下模式来自教材与配套代码的结构性蒸馏。替换大写占位符；先完成协议和数据审计。不要在运行脚本时调用 `install.packages()`。

## 二分类风险模型

```r
dd <- rms::datadist(dat)
options(datadist = "dd")

fit_bin <- rms::lrm(
  EVENT ~ rms::rcs(AGE, 4) + BIOMARKER + SEX + TREATMENT,
  data = dat, x = TRUE, y = TRUE
)

odds_ratio <- exp(cbind(OR = coef(fit_bin), confint(fit_bin)))
prob <- predict(fit_bin, newdata = dat, type = "fitted")
```

确认 `EVENT` 的事件层级、因子参考水平和绝对风险窗口。`lrm()` 适合 `rms` 的验证、校准和列线图；若使用 `glm()`，用 `type = "response"` 获得概率，而非线性预测值。

## 多分类、有序与匹配病例对照

```r
# 无序多分类；显式设置 OUTCOME 和所有 factor 的参考水平。
fit_multi <- nnet::multinom(OUTCOME ~ AGE + SEX + BIOMARKER, data = dat)

# 有序结局；只有比例优势假设合理时使用。
fit_ord <- MASS::polr(ORDERED_OUTCOME ~ AGE + SEX + BIOMARKER,
                      data = dat, Hess = TRUE)

# 匹配病例对照；MATCH_SET 必须标识完整匹配层。
fit_match <- survival::clogit(CASE ~ EXPOSURE + COVARIATE + strata(MATCH_SET),
                              data = dat)
```

为多分类模型逐类别报告概率/性能；不要以二分类 AUC 代替所有类别的评价。对有序模型诊断比例优势假设。对条件 Logistic，绝不打散匹配集。

## Cox 预后模型

```r
dd <- rms::datadist(dat)
options(datadist = "dd")

fit_cox <- rms::cph(
  survival::Surv(FOLLOW_UP_DAYS, EVENT == 1) ~
    rms::rcs(AGE, 4) + SEX + BIOMARKER,
  data = dat, x = TRUE, y = TRUE, surv = TRUE
)

ph <- survival::cox.zph(fit_cox)
print(ph)
plot(ph)

survival_function <- rms::Survival(fit_cox)
surv_1y <- function(lp) survival_function(times = 365, lp = lp)
```

将 `EVENT == 1` 替换为实际目标事件。保留 `x=TRUE, y=TRUE, surv=TRUE`，以支持 `rms` 的预测、校准和验证。绘制 `cox.zph()` 中每个变量与总体检验；显著性并不能替代图形和临床判断。

## 竞争风险绝对风险模型

```r
# STATUS: 0 = censor, 1 = target cause, 2+ = competing cause(s).
fit_fgr <- riskRegression::FGR(
  prodlim::Hist(FOLLOW_UP_DAYS, STATUS, cens.code = 0) ~ AGE + SEX + BIOMARKER,
  data = dat,
  cause = 1
)

# 原因特异风险模型；适用于需要每种原因特异风险的预测。
fit_csc <- riskRegression::CSC(
  prodlim::Hist(FOLLOW_UP_DAYS, STATUS, cens.code = 0) ~ AGE + SEX + BIOMARKER,
  data = dat
)
```

先画 `cmprsk::cuminc()` 得到分组 CIF 和 Gray 检验；随后选择与预测问题对应的 FGR 或 CSC。不要将 `cmprsk::crr()` 的原始线性预测器直接当作某一时点的风险；使用能明确输出 CIF 的预测函数并在验证数据上评价。

## 收缩与机器学习

```r
x <- model.matrix(EVENT ~ AGE + SEX + BIOMARKER + OTHER_FACTOR, dat)[, -1]
y <- dat$EVENT

set.seed(20260714)
fit_lasso <- glmnet::cv.glmnet(
  x = x, y = y, family = "binomial", alpha = 1,
  type.measure = "deviance", nfolds = 10
)
coef(fit_lasso, s = "lambda.1se")
```

使用 `lambda.1se` 与 `lambda.min` 的选择必须事先说明。若要报告调参模型的性能，将整个 `model.matrix`、预处理、CV 与 `lambda` 选择放入外层重抽样。对于 Cox LASSO，使用 `survival::Surv(time, event)` 作为 `y` 并设 `family = "cox"`。

随机森林可用 `randomForestSRC::rfsrc()` 拟合连续、分类、生存或竞争风险结局。固定种子，报告 `ntree`、`mtry`、`nodesize`、分裂规则、缺失值处理和 OOB/外部性能；将变量重要性限定为模型内探索。

## 列线图

仅为已经验证、可解释并明确预测时点的最终模型绘制列线图。使用 `rms::datadist()` 后：

```r
nom <- rms::nomogram(
  fit_cox,
  fun = list(surv_1y),
  funlabel = "1-year survival probability",
  lp = TRUE
)
plot(nom)
```

二分类模型可使用 `plogis` 转换线性预测器。列线图不能补偿过拟合、错误校准或不适用人群。

