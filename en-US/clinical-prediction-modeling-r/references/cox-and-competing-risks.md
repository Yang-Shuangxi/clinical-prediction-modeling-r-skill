# Cox and competing risks

## Cox proportional hazards

Before using Cox regression, confirm that the target is time to an event with censoring and that proportional hazards is acceptable over the interpretation or prediction interval. Report the number of participants, target events, censoring, median follow-up, time zero, units, event coding, prediction time, and when each predictor becomes available.

At minimum, inspect:

- variable-level and global `survival::cox.zph()` results and Schoenfeld residual plots;
- the functional form of continuous predictors, preferably with restricted cubic splines;
- influential observations, missingness, and possible center/batch effects;
- calibration and discrimination at prespecified times rather than only HR or overall C-index.

If proportional hazards fails, identify the variable and time interval affected. Consider stratified Cox, time interactions, flexible parametric models, or another model; do not hide a violated assumption.

## Interpreting Cox predictions

An HR is a relative instantaneous hazard, not a fixed-time absolute risk. Clinical prediction deliverables must report survival probability or event risk at a target time with calibration and uncertainty. Use `rms::cph(..., surv=TRUE)` with `rms::Survival()` or another validated prediction tool to generate absolute predictions.

## Competing risks

Distinguish:

- cause-specific hazard: after a competing event, the person is no longer in the target-event risk set;
- subdistribution hazard (Fine-Gray): linked to the cumulative incidence function;
- CIF: the absolute probability of the target event by a given time in the presence of competing events.

When individual absolute risk is the deliverable, report the CIF, target cause, and time point. Use `cmprsk::cuminc()` for descriptive CIFs and `riskRegression::FGR()` or `riskRegression::CSC()` for modeling and prediction. `crr()` requires a manually constructed numeric covariate matrix and can create factor-coding errors; preserve the design matrix and references when using it.

Treating competing events as ordinary censoring usually overestimates absolute target-event risk. For etiologic association rather than absolute prediction, state in advance whether the cause-specific or Fine-Gray interpretation is intended.

## Evaluation with competing risks

At every prespecified time, report methods compatible with competing risks: CIF calibration, time-dependent discrimination, Brier score or prediction error, and uncertainty. Do not call a cause-specific HR a CIF or an individual risk.
