# Analysis protocol, data, and bias control

## Minimum input before modeling

Record the purpose, outcome, prediction time, expected clinical action, enrollment rules, analysis unit, data source, candidate predictors, missingness assumptions, and validation cohort. For prognosis, define time zero; post-time-zero information cannot be a baseline predictor.

Fix a variable dictionary containing name, type, unit, allowed range, reference, missing code, measurement time, and permitted transformations. Make the event level explicit and audit censoring and each competing event separately. Run `scripts/clinical_model_checks.R` before clinical review.

## Splitting and leakage

Prefer temporal, geographic, hospital, or cohort-held-out external validation. If a random split is unavoidable, retain participant IDs, stratify by outcome, and keep the same participant, matching set, or center-related record out of both training and test data. One split is not a substitute for internal resampling.

Fit imputation, outlier rules, standardization, transformations, feature engineering, selection, tuning, and thresholds only in training data and repeat them within each bootstrap or cross-validation resample. Apply locked training rules to validation data.

### Nested resampling and multiple imputation

When selecting tuning parameters, perform inner resampling inside each outer training fold. Generate outer assessment predictions only after model and preprocessing are locked. Multiple imputation is also part of fitting: train the imputation model inside each outer training fold and apply its rules to assessment data without using assessment outcomes. Save IDs, predictions, tuning parameters, seeds, and failure states. Compare models on the same outer out-of-fold or external predictions.

## Missing data and sample size

Do not use `na.omit()` by default. Report missingness per variable, complete-case counts, and whether exclusions differ by time, center, or outcome. If complete-case analysis is justified, explain why; otherwise use a compatible multiple-imputation strategy that includes outcomes, candidate predictors, and auxiliary variables.

Relate model complexity to usable participants and events. Count categorical levels, spline degrees of freedom, interactions, and tuning freedom. With small samples or rare events, reduce the prespecified candidate set, use shrinkage/penalization, and emphasize uncertainty rather than manufacturing a variable list with univariable p-values.

## Continuous predictors, factors, and nonlinearity

Keep continuous predictors on meaningful scales and explore functional form with plots, partial effects, and restricted cubic splines. Do not search for an optimal cutoff and then present confirmatory performance. Set categorical predictors as factors and record reference levels; do not encode categories as equally spaced integers.

## The role of variable selection

Selection can be useful for a stated prediction goal, but it is not a substitute for prespecification, shrinkage, validation, or clinical review. Report the selection rule, tuning process, instability, and how it was nested in resampling.
