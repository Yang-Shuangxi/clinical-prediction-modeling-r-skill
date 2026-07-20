# Validation, performance, and clinical utility

## Calibration

Calibration asks whether predicted risk agrees with observed risk. For binary models, report a calibration curve and, where appropriate, calibration intercept and slope. For survival or competing-risk models, evaluate calibration at clinically relevant prespecified times. A development-set curve is apparent calibration, not validation.

```r
# Bootstrap optimism-corrected calibration for a binary or Cox model.
cal <- rms::calibrate(fit, method = "boot", B = 1000)
plot(cal)

# Time-specific evaluation and comparison for survival/competing risks.
score <- riskRegression::Score(
  object = list(model = fit),
  formula = survival::Surv(TIME, EVENT) ~ 1,
  times = c(365, 1095),
  metrics = c("auc", "brier"),
  plots = c("calibration", "ROC"),
  data = validation_data
)
```

For competing risks, use a `prodlim::Hist()` formula and set `cause`. Do not call a development-only quantile/observed-risk plot external calibration.

## Discrimination and overall error

- Binary: AUC/C-index with 95% CI; confirm event direction when using `pROC::roc()`.
- Survival: time-dependent AUC at prespecified times with the censoring-weighting method stated.
- Cox: report Harrell C-index and uncertainty, but do not use it instead of fixed-time calibration; `summary(coxph_fit)$concordance` is a quick diagnostic.
- Overall error: supplement with Brier score or prediction-error curves, especially with censoring.

Compare models on the same external or out-of-fold predictions and use paired uncertainty. Report complete and reduced models, time points, and confidence intervals. Do not claim superiority from tiny development-set AUC differences.

## Clinical utility

Use decision-curve analysis only across clinically defensible thresholds. Define the risk time point, treatment threshold, treat-all, treat-none, and clinical consequences. DCA is not a replacement for calibration or external validation.

## Validation

Prefer temporal, geographic, or independent-cohort validation. Without external data, use bootstrap optimism correction or repeated/nested cross-validation. A single random 70:30 split is not sufficient evidence of transportability.
