# R modeling patterns

These patterns are a structural synthesis of the teaching materials and companion code. Replace uppercase placeholders only after completing the protocol and data audit. Do not call `install.packages()` from an analysis script.

## Binary risk models

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

Confirm the event level, factor references, and absolute-risk window. `lrm()` integrates with `rms` validation, calibration, and nomograms; with `glm()`, use `type = "response"` for probabilities rather than the linear predictor.

## Multiclass, ordered, and matched case-control outcomes

```r
# Unordered multiclass; set OUTCOME and factor references explicitly.
fit_multi <- nnet::multinom(OUTCOME ~ AGE + SEX + BIOMARKER, data = dat)

# Ordered outcome; use only when the proportional-odds assumption is reasonable.
fit_ord <- MASS::polr(ORDERED_OUTCOME ~ AGE + SEX + BIOMARKER,
                      data = dat, Hess = TRUE)

# Matched case-control; MATCH_SET must identify complete matching strata.
fit_match <- survival::clogit(CASE ~ EXPOSURE + COVARIATE + strata(MATCH_SET),
                              data = dat)
```

## Cox proportional hazards

```r
fit_cox <- survival::coxph(
  survival::Surv(FOLLOW_UP, EVENT) ~ AGE + SEX + BIOMARKER,
  data = dat, ties = "efron", x = TRUE, y = TRUE, model = TRUE
)

hr_table <- broom::tidy(fit_cox, exponentiate = TRUE, conf.int = TRUE)
ph_test <- survival::cox.zph(fit_cox, transform = "km")
```

Report time zero, time units, event/censoring codes, HR interpretation, PH diagnostics, and absolute risk or survival at prespecified times. Keep continuous predictors continuous unless a threshold is clinically prespecified.

## Competing risks

```r
ci <- cmprsk::cuminc(ftime = TIME, fstatus = STATUS, group = GROUP, data = dat)
fit_fg <- riskRegression::FGR(
  Hist(TIME, STATUS) ~ AGE + SEX + BIOMARKER,
  data = dat, cause = 1
)
```

State the target cause, competing-event code, prediction time, and whether the model is cause-specific or Fine-Gray. Evaluate CIF calibration and time-dependent discrimination with a validation sample or honest resampling.

## Validation and reporting

Use bootstrap or nested/repeated resampling when estimating performance or tuning. Report calibration, discrimination, Brier/error, clinical utility, uncertainty, and external-validation boundaries. `summary(coxph_fit)$concordance` is a quick diagnostic, not complete validation.
