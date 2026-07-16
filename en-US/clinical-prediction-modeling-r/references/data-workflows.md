# Clinical data contracts, import, and wrangling

Before any model, define the observation unit, key, time meaning, and purpose of every table. This file addresses whether data are suitable for modeling; missingness, leakage, and validation boundaries are covered in [workflow.md](workflow.md).

## Contents

- [1. Write the data contract](#1-write-the-data-contract)
- [2. Fix key types at import](#2-fix-key-types-at-import)
- [3. Table relationships and safe joins](#3-table-relationships-and-safe-joins)
- [4. Dates, time, and prediction time](#4-dates-time-and-prediction-time)
- [5. Fixed-window outcomes and follow-up](#5-fixed-window-outcomes-and-follow-up)
- [6. Categories, continuous values, missingness, and anomalies](#6-categories-continuous-values-missingness-and-anomalies)
- [7. The pre-model gate](#7-the-pre-model-gate)

## 1. Write the data contract

For every input table, record its version/date, row entity (patient, visit, test, sample, or center), primary and foreign keys, source/unit/allowed values/missing codes, measurement time, and earliest time at which a field can enter prediction. The analysis table must also state what one row represents.

A baseline fixed-window model usually has one row per participant. A survival model can have one row per participant or a prespecified start-stop interval. Repeated visits or laboratory tables are not baseline tables. Do not infer a key from columns that merely happen to be unique; the key needs domain meaning.

Recommended minimum layout:

```text
project/
  data/raw/              # read-only source files
  data/derived/          # script-generated intermediate/analysis data
  data-dictionary/       # fields, codes, units, time, versions
  scripts/               # 01_import.R, 02_derive.R, 03_model.R, ...
  reports/               # .Rmd or .qmd sources
  outputs/               # figures, tables, models, audits
  renv.lock
```

Run from the project root with relative paths. Never use personal absolute paths, `setwd()`, or `.RData` state transfer in a deliverable script.

## 2. Fix key types at import

Explicitly declare types for IDs, dates, outcomes, categorical fields, and numeric predictors. Preserve leading zeros in IDs. After import, audit column names, row counts, duplicate keys, parse failures, unexpected levels, units, and missing-code conventions. Treat automatic type guesses as hypotheses to audit, not as a contract.

For Excel files, inspect sheet names, header rows, merged cells, blank columns, date serials, and formulas. For CSV files, set encoding, delimiter, decimal mark, and locale. Keep the raw file read-only and save a manifest or checksum for reproducibility.

## 3. Table relationships and safe joins

Before a join, state the left and right keys and expected relationship: one-to-one, one-to-many, or many-to-one. Audit key uniqueness and unmatched records on both sides. A many-to-many join can silently duplicate participants and change the analysis unit; fail or aggregate explicitly.

Longitudinal records require a prespecified summary rule, such as first available baseline value, last value before time zero, mean over a window, or a start-stop design. Do not connect repeated measurements directly to a one-row baseline table.

## 4. Dates, time, and prediction time

Define time zero and the allowable baseline window. Confirm that follow-up time is non-negative, that events do not occur before time zero unless left truncation is modeled, and that censoring is coded separately from target and competing events. Preserve time zones and distinguish a display conversion from correction of a wrong source time zone.

## 5. Fixed-window outcomes and follow-up

For a fixed-window outcome, define the window, event ascertainment, competing outcomes, and status coding. For survival data, report follow-up units, minimum/median/maximum follow-up, event counts, censoring counts, and any excluded zero-time records. Do not silently convert impossible or missing times to zero.

## 6. Categories, continuous values, missingness, and anomalies

Record category levels and references explicitly. Keep `unknown`, `not applicable`, and `not measured` distinct when they have different meanings. Normalize spelling/whitespace only with an auditable rule and preserve the original count. Do not silently turn an unknown category into a missing value.

Keep continuous variables continuous unless a clinical threshold was prespecified. Audit ranges, units, impossible values, outliers, and duplicate measurements. Report missingness for every modeling field, by outcome and key time/center strata where relevant.

## 7. The pre-model gate

Do not fit a model until these checks have been reviewed:

1. The analysis unit and key are unique or the repeated-measures structure is explicit.
2. Time zero, outcome/event code, censoring, and competing events are documented.
3. All predictors are available at prediction time and have validated units.
4. Unexpected values, parse failures, duplicate keys, and unmatched joins have an explained disposition.
5. Missingness, exclusions, and complete-case counts are reported.
6. The formula, factor references, random seed, package versions, and input manifest are saved.
