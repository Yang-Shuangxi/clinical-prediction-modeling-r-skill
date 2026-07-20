---
name: clinical-prediction-modeling-r
description: Construct, validate, and report reproducible clinical disease-risk prediction models in R. Use for Chinese or English requests involving clinical prediction models, clinical data import or wrangling, data dictionaries, safe table joins, diagnostic or prognostic models, linear/Logistic/Cox/competing-risk models, LASSO, random forests, nomograms, calibration, ROC/AUC/C-index, DCA, resampling, external validation, or R Markdown/Quarto model reports.
---

# Clinical Prediction Modeling in R

## Purpose and boundaries

Build reproducible research-grade prediction models rather than individual medical advice or an immediately deployable clinical decision rule. Before coding, define the intended use, prediction time, target population, available predictors, and validation strategy. If the outcome, time zero, target event, or prediction time is unclear, ask before modeling; never fill in a default silently.

Record the current R and package versions in the deliverables. Do not present apparent development-set performance as final performance or claim clinical usability without appropriate independent validation, clinical utility assessment, and governance.

## Establish an analysis protocol

Before modeling, record:

| Item | Required content |
| --- | --- |
| Research question | Diagnosis or prognosis; decision the model may support |
| Population | Inclusion/exclusion, center/time range, unit of analysis, leakage risks |
| Outcome | Coding, ascertainment, availability, prediction window |
| Time axis | Time zero, units, censoring, competing-event codes |
| Predictors | Availability at prediction time, units, missingness, clinical rationale |
| Development and validation | Temporal/geographic external validation or resampling strategy |
| Performance and utility | Calibration, discrimination, overall error, thresholds, comparators |

Read [workflow.md](references/workflow.md) for data preparation, missingness, sample size, and leakage control. For small samples, rare outcomes, multi-center data, missing data, machine learning, or model updating, read it before writing model code.

## Data contract and reproducible workflow

When data come from EHRs, registries, CSV/Excel files, multiple sheets, or longitudinal tables, read [data-workflows.md](references/data-workflows.md) and define the data contract.

1. Treat raw files as read-only evidence. Make cleaning, derived variables, and analysis data explicit and runnable; declare the analysis unit and keep one row per unit unless a start-stop design is prespecified.
2. Define IDs, outcomes, prediction time, dates, units, allowed values, and missing codes. Fix key import types and fail on parse errors, duplicate keys, unexpected values, or impossible time order.
3. Before every join, state the keys and expected relationship. Audit unmatched records and many-to-many expansion. Do not join repeated visits or laboratory records to a baseline row without a declared aggregation.
4. Establish time zero. Baseline predictors must be available at that time or in an explicitly allowed window. Preserve source time zones and distinguish display conversion from correction of an incorrect time zone.
5. Use exploratory plots and missingness audits to detect problems, not to select outcome-driven cutoffs or preprocessing rules before claiming independent validation. Estimate preprocessing inside training/resampling when it affects the model.

Read [reproducible-reporting.md](references/reproducible-reporting.md) when scripts, package versions, input manifests, random seeds, and reports must be rerunnable.

## Choose a model for the outcome

| Outcome and goal | Preferred R path | Further reading |
| --- | --- | --- |
| Continuous outcome | `stats::lm()`; inspect linearity, residuals, and heteroscedasticity | [modeling-patterns.md](references/modeling-patterns.md) |
| Fixed-window binary risk | `rms::lrm()` or `stats::glm(..., family=binomial)` | [modeling-patterns.md](references/modeling-patterns.md) |
| Unordered/ordered categorical outcome | `nnet::multinom()` / `MASS::polr()` after checking assumptions | [modeling-patterns.md](references/modeling-patterns.md) |
| Matched case-control | `survival::clogit()` with the matching stratum retained | [modeling-patterns.md](references/modeling-patterns.md) |
| Single-event time-to-event risk | `survival::coxph()` or `rms::cph()`; report absolute survival/risk at prespecified times | [cox-and-competing-risks.md](references/cox-and-competing-risks.md) |
| Absolute risk with competing events | Target cumulative incidence; use `riskRegression::FGR()` or `CSC()` | [cox-and-competing-risks.md](references/cox-and-competing-risks.md) |

Do not choose Cox merely because follow-up data exist, or treat competing events as ordinary censoring. Choose the model according to the quantity to be predicted: survival, cause-specific risk, or cumulative incidence.

## General implementation rules

1. Preserve continuous predictors on a meaningful scale. Explore nonlinear functional forms with prespecified restricted cubic splines; do not data-drive binary cutoffs unless clinically prespecified.
2. Prespecify candidate predictors using clinical knowledge, time availability, and the prediction target. Do not use univariable screening, stepwise selection, best-subset selection, or random-forest importance as the sole selection rule. If used, embed it in resampling and report instability.
3. State missing-data assumptions. If using multiple imputation, fit imputation, selection, standardization, and tuning inside every training/resampling loop.
4. Use nested cross-validation or bootstrap for LASSO, random forests, and other tuned models. Preserve the grid, preprocessing, seed, and all performance estimates.
5. Run `scripts/data_contract_checks.R` and `scripts/clinical_model_checks.R` before clinical review. These structural checks do not replace clinical adjudication.
6. Save the data dictionary, formula, factor reference levels, imputation rules, seed, package versions, and final objects explicitly.

Read [modeling-patterns.md](references/modeling-patterns.md) before implementing a model. It provides adaptable patterns for linear, Logistic, Cox, competing-risk, LASSO, random-forest, and nomogram workflows.

## Cox and competing-risk checks

For every Cox model:

1. State what `event=1` means in `Surv(time, event)` and audit time zero, units, left truncation, and censoring.
2. Check proportional hazards with `cox.zph()` and plots, and check continuous functional form. If violated, consider stratification, time interactions, flexible parametric models, or another model and report the decision.
3. Translate linear predictors into survival or event risk at prespecified times. HR is not an individual absolute risk.
4. With competing events, report the event coding, target cause, CIF, and selected risk model. Do not mix Fine-Gray subdistribution HR with Cox HR or CIF.

Read [cox-and-competing-risks.md](references/cox-and-competing-risks.md) for Cox, Fine-Gray, CIF, time-dependent AUC/calibration, and competing-risk nomogram workflows.

## Evaluation, comparison, and validation

Evaluate on predictions not used for fitting, tuning, or feature selection, or use resampling that corrects the complete optimism-generating process.

1. **Calibration:** report calibration curves and intercept/slope where appropriate; for survival and competing risks, evaluate at prespecified times.
2. **Discrimination:** report AUC/C-index with uncertainty; for survival, use time-dependent measures and describe censoring weights.
3. **Overall error and utility:** supplement with Brier score/error curves and use decision-curve analysis only over clinically defensible thresholds.
4. **Comparison:** compare models on the same external or out-of-fold predictions with paired uncertainty; do not claim superiority from tiny development-set AUC differences.
5. **Validation:** prefer temporal, geographic, or independent-cohort validation. Without external data, use bootstrap or repeated/nested cross-validation; a single random split is not sufficient validation.

Read [validation-and-performance.md](references/validation-and-performance.md) for `rms`, `riskRegression`, `pROC`, `pec`, `dcurves`, and resampling patterns.

## Deliverables

Provide, in order:

1. The analysis protocol, data dictionary, import/key/time audits, and analysis unit.
2. A clean-session script or R Markdown/Quarto source with package-install instructions outside the analysis run.
3. R/package versions, input manifest/checksums, random seed, and `sessionInfo()`.
4. Model formulas, effect estimates, and how individual risk is calculated.
5. Calibration, discrimination, overall error, decision-curve, and internal/external validation results with uncertainty.
6. Assumption diagnostics, missing-data handling, limitations, intended population, and out-of-scope uses.
7. TRIPOD+AI and PROBAST self-checks for manuscript-ready reporting.

Read [source-scope.md](references/source-scope.md) for the educational sources and scope of this skill. It is an original synthesis, not a line-by-line copy of a textbook or code repository. Confirm current function arguments against installed package documentation.
