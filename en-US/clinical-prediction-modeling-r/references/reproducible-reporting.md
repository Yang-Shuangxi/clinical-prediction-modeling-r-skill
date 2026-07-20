# Reproducible execution, batch models, and reporting

The goal is for another researcher to regenerate analysis data, models, tables, figures, and reports from a clean session, controlled inputs, and recorded package versions. Reproducibility does not remove bias; it makes decisions, versions, and limitations auditable.

## 1. Run from a clean session

Use scripts, not an interactive workspace, as the source of truth. Separate import, derivation, modeling, validation, and reporting into ordered scripts. Each step must read a controlled output or call a function file; never depend on accidental `.GlobalEnv` objects.

```sh
Rscript --vanilla scripts/01_import.R
Rscript --vanilla scripts/02_derive_analysis_data.R
Rscript --vanilla scripts/03_develop_validate.R
Rscript --vanilla -e 'rmarkdown::render("reports/model-report.Rmd")'
```

Run from the project root and use relative paths such as `file.path("data", "raw", "baseline.csv")`. Set all random seeds at the start. When using parallelism or random tuning, record the random-number strategy, workers, and seed. Do not call `install.packages()` while analysis or reporting is running.

## 2. Pin packages and input versions

Use `renv` for projects that need reproducibility or sharing. Commit `renv.lock`, not participant-level raw data. Restore with `renv::restore()` and update only after the scripts work; use `renv::status()` before delivery.

```r
renv::init()       # once while establishing the project
renv::snapshot()   # after packages and scripts are verified
renv::status()
```

Report the R version, operating system, external tools, rendering versions, input filenames, dates, de-identified version IDs, or checksums. Never publish identifiable paths or patient IDs.

```r
input_files <- c("data/raw/baseline.csv", "data/raw/outcomes.csv")
run_manifest <- data.frame(
  file = input_files,
  md5 = unname(tools::md5sum(input_files)),
  stringsAsFactors = FALSE
)
```

## 3. Batch fitting and failure logs

Use functions and explicit model specifications for batches of outcomes or predictors. Return one tidy result object per model and preserve warnings, convergence failures, dropped rows, and formula metadata. Do not copy-paste formulas with silent changes.

## 4. Reports and model objects

Use R Markdown or Quarto to combine protocol, code, results, and figures. Save the analysis data dictionary, model formula, factor references, pre-processing decisions, diagnostics, performance predictions, and session information. Do not save `.RData` as an implicit handoff mechanism.

## 5. Public release checklist

Before release, confirm that no raw data, patient identifiers, local absolute paths, credentials, generated private outputs, or copyrighted textbook scans are tracked. Use synthetic data for examples and provide a short reproducibility command.
