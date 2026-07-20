# Clinical Prediction Modeling in R Codex Skill: Installation and Usage Guide

[简体中文版本] Please turn to the Chinese edition folder.

A bilingual Codex skill for research-grade, reproducible clinical prediction modeling in R. It covers data contracts, typed data import and checks, Logistic regression, Cox proportional-hazards models, competing risks, calibration, discrimination, clinical utility, and transparent reporting.

> This repository contains only the Codex skill and its documentation. It does not contain patient data, study results, textbook PDFs, or textbook scans. The project does not provide individual medical advice, and no model should be described as ready for clinical deployment without appropriate external validation, calibration, clinical-utility assessment, and governance review.

## Contents

- [Highlights](#highlights)
- [Knowledge sources](#knowledge-sources)
- [Repository structure](#repository-structure)
- [Installation](#installation)
- [Confirming installation](#confirming-installation)
- [What to prepare](#what-to-prepare)
- [Recommended prompt](#recommended-prompt)
- [Cox analysis prompt example](#cox-analysis-prompt-example)
- [Recommended workflow](#recommended-workflow)
- [Example outputs](#example-outputs)
- [Reproducibility, safety, and verification](#reproducibility-safety-and-verification)
- [Contributing and feedback](#contributing-and-feedback)
- [Citation and license](#citation-and-license)

## Highlights

- **Less repetitive coding:** Common clinical prediction steps are organized as reusable workflows. The “70% time saving” statement in the source tutorial reflects the author's personal experience and is not a performance guarantee for every task.
- **Data-contract first:** Variable meanings, types, coding, missing values, time units, outcomes, and inclusion/exclusion rules are established before model fitting.
- **Common research models:** Workflows cover Logistic, Cox, and competing-risk analyses.
- **Validation and reporting:** The skill emphasizes proportional-hazards diagnostics, calibration, discrimination, clinical utility, internal or external validation, and transparent reporting.
- **Reproducible deliverables:** Requests may require an annotated R script, processing log, intermediate results, tables, and vector figures.
- **Bilingual packages:** Install either the Chinese or English skill package.

## Knowledge sources

The skill is an original methodological synthesis informed initially by:

1. Xianzhen Peng, *Practical Clinical Prediction Modeling in R*, ISBN 978-7-302-62111-9.
2. Hadley Wickham and Garrett Grolemund, *R for Data Science* (Chinese edition ISBN 978-7-115-48639-4).

Future versions may incorporate additional authoritative textbooks, statistical guidance, reporting standards, and official software documentation. The repository provides original synthesis and links to authoritative sources; it does not redistribute textbook text, scans, or complete textbook code.

## Repository structure

```text
clinical-prediction-modeling-r-skill/
├── README.md
├── LICENSE
├── CITATION.cff
├── CONTRIBUTING.md
├── SECURITY.md
├── CODE_OF_CONDUCT.md
├── zh-CN/
│   └── clinical-prediction-modeling-r/
│       ├── SKILL.md
│       ├── agents/openai.yaml
│       ├── references/
│       └── scripts/
├── en-US/
│   └── clinical-prediction-modeling-r/
│       ├── SKILL.md
│       ├── agents/openai.yaml
│       ├── references/
│       └── scripts/
└── scripts/validate_skill.py
```

The `clinical-prediction-modeling-r/` directory in each language folder is an independently installable skill:

- `SKILL.md`: core workflow, trigger scope, and analysis principles;
- `agents/openai.yaml`: Codex UI metadata;
- `references/`: guidance for data work, modeling, Cox and competing risks, validation, and reporting;
- `scripts/`: R functions for data-contract and clinical-model structural checks.

## Installation

### Option 1: Ask Codex to assist

Send the following request to Codex and replace the URL with the actual repository URL:

```text
Please download clinical-prediction-modeling-r-skill from this GitHub repository:
https://github.com/yangkaikai/clinical-prediction-modeling-r-skill

Install en-US/clinical-prediction-modeling-r in my Codex skills directory.
Check that SKILL.md and all required files are present, then report the installation path and validation result.
```

### Option 2: Install the English package manually

```bash
git clone https://github.com/yangkaikai/clinical-prediction-modeling-r-skill.git
mkdir -p ~/.codex/skills
cp -R clinical-prediction-modeling-r-skill/en-US/clinical-prediction-modeling-r ~/.codex/skills/
```

To install the Chinese package, replace `en-US` with `zh-CN`. Both packages use the same installation directory name, so only one can occupy that location at a time. Back up or replace the existing package when switching languages.

> If the GitHub owner or repository name differs, update the URL in the commands accordingly.

## Confirming installation

Restart Codex after installation. In a new task, type `$clinical-prediction-modeling-r` or search the skill picker for **Clinical Prediction Models in R**. Finding and selecting the skill normally confirms that it is installed.

![Clinical Prediction Models in R in the Codex skill picker](assets/codex-skill-menu.webp)

Use this simple test request:

```text
Use $clinical-prediction-modeling-r.
Describe the models this skill supports, its required inputs, default quality checks, and possible deliverables.
Do not analyze data yet.
```

## What to prepare

### 1. A data dictionary

Prepare a Markdown, Excel, or CSV data dictionary containing at least:

- column names and meanings;
- variable types: continuous, nominal categorical, ordinal, date/time, or time-dependent;
- units, expected ranges, and category coding;
- meanings of missing, `unknown`, refusal, or special-value codes;
- definitions of exposures, outcomes, follow-up time, event status, and covariates;
- prespecified inclusion, exclusion, and data-cleaning rules.

### 2. The data file

Upload the file or provide its absolute local path. For medical data, restrict reading and output to a local working directory. Do not provide direct patient identifiers, insufficiently de-identified data, credentials, or unauthorized materials.

### 3. A precise analysis request

Specify at least:

- the research question and target model;
- exposure, outcome, follow-up time, and candidate covariates;
- univariable, multivariable, nonlinear, interaction, or sensitivity-analysis requirements;
- missing-data strategy and variable-type rules;
- required tables, figures, file formats, and output directory;
- whether to provide R scripts, logs, data-processing notes, and QA results.

### 4. Target tables or figures

If a specific style is required, attach an example and identify the features that must be reproduced, such as column headings, reference groups, colors, fonts, axes, confidence intervals, and footnotes.

## Recommended prompt

```text
Use $clinical-prediction-modeling-r.

Read the data and data dictionary before fitting any model. First report:
1. dimensions, variable names, and inferred data types;
2. the identified exposure, outcome, follow-up time, and covariates;
3. missing values, unusual codes, duplicate records, and invalid time values;
4. proposed variable types, reference levels, inclusion/exclusion rules, and missing-data strategy;
5. ambiguities that require my confirmation.

Data file: [local path or uploaded filename]
Data dictionary: [local path or uploaded filename]
Working directory: [output directory]

After the data contract is confirmed, perform: [specific analysis].

Deliver:
- a fully reproducible R script with clear comments;
- a Markdown explanation of data processing and model construction;
- complete result tables;
- requested figures and formats;
- a work log and quality-check results.

Do not change the outcome definition, follow-up units, reference groups, or prespecified exclusion criteria without asking me.
```

![Example analysis prompt in Codex](assets/prompt-example.webp)

## Cox analysis prompt example

The following template covers exposure quartiles, univariable models, and all-covariate multivariable Cox models. Replace all bracketed fields.

```text
Use $clinical-prediction-modeling-r.

Perform a Cox proportional-hazards analysis within the local working directory.

Data file: [path]
Data dictionary: [path]
Output directory: [path]
Target forest-plot example: [optional image path]

Study definitions:
- Follow-up variable: [name and unit]
- Event-status variable: [name and meaning of 0/1]
- Exposure variables: [exposure 1, exposure 2, ...]
- Candidate covariates: [explicit list; state if every listed covariate must be included]
- Exclusion rules: [prespecified rules]
- Missing-data strategy: [complete cases, multiple imputation, or another prespecified method]

Analysis requirements:
1. Reconcile the data dictionary and classify each variable as continuous, nominal, ordinal, or time-dependent.
2. For each continuous exposure, calculate quartile cut points in the analysis sample and create Q1–Q4, using Q1 as the reference. Report cut points, sample size, and event count per group, and address tied cut points explicitly.
3. Fit a separate univariable Cox model for each exposure.
4. Fit a separate multivariable Cox model for each exposure using all prespecified covariates. Do not select covariates by univariable P values.
5. Report HRs, 95% CIs, P values, and P for trend, including the coding used for the trend test.
6. Test the proportional-hazards assumption globally and by model term. If it is violated, report the violation and propose an interpretable, prespecified remedy rather than ignoring it.
7. For multivariable models only, produce Q1–Q4 adjusted survival curves or state the standardization method used. Do not label unadjusted KM curves as adjusted KM curves.
8. Produce separate univariable and multivariable forest plots matching the supplied example where practical, and provide editable result tables.

Deliverables:
- complete R script with comments;
- explanation of data cleaning and treatment of every column;
- univariable and multivariable result tables in CSV/XLSX;
- vector PDF forest plots and survival curves;
- proportional-hazards diagnostic plots;
- Markdown analysis report and work log;
- sessionInfo() or an equivalent environment record.

First provide a data audit and modeling plan. Pause and ask me if the variable definitions, time origin, event coding, or covariate treatment contain material ambiguities.
```

## Recommended workflow

1. **Clarify scope:** Ask Codex what the skill supports and where its limits are.
2. **Define inputs and outputs:** Provide the data, dictionary, example figure, working directory, and deliverable list.
3. **Audit before modeling:** Confirm variable types, coding, missing data, exclusion rules, and time definitions.
4. **Require reproducibility:** Request the R script, environment information, random seed, processing log, and intermediate results.
5. **Review manually:** Reconcile sample sizes, event counts, formulas, reference groups, HRs/CIs, diagnostic tests, and figures before using the results in a study report.

## Example outputs

The following images come from the source tutorial and illustrate possible output types. They are not fixed outputs for arbitrary datasets and do not constitute clinical findings.

### Exposure-distribution comparison

![Example exposure-distribution comparison](assets/exposure-distribution-example.webp)

### Nonlinear dose–response association

![Example restricted cubic spline or continuous-exposure risk curve](assets/nonlinear-association-example.webp)

### Univariable forest plot

![Example univariable Cox forest plot](assets/univariable-forest-example.webp)

### Multivariable forest plot

![Example multivariable Cox forest plot](assets/multivariable-forest-example.webp)

### Proportional-hazards diagnostics

![Example Cox proportional-hazards diagnostic plot](assets/ph-diagnostics-example.webp)

The source tutorial reports one validation exercise using UK Biobank air-pollution exposures and a heart-failure outcome: automated and manually coded analyses agreed when the same preprocessing and model specification were used. This is a task-specific check and does not imply perfect agreement for every dataset, model, or prompt.

## Reproducibility, safety, and verification

- Treat source data as read-only and write results to a separate directory.
- Do not commit patient data, credentials, textbook PDFs, internal paths, or restricted materials to a public repository.
- Record the source sample size, every exclusion, the final analysis sample, and event counts.
- Document cleaning, recoding, reference levels, and missing-data handling for every variable.
- Set random seeds and record R, package versions, and `sessionInfo()`.
- Independently review critical results; automation does not replace statistical judgment, clinical interpretation, or research governance.
- Reconcile sample sizes, HRs, 95% CIs, and P values across tables, figures, and narrative text.
- Do not select adjustment variables solely by P values; prefer the research question, causal structure, and a prespecified analysis plan.

## Contributing and feedback

The skill can continue to incorporate new methodological evidence, validation strategies, and reporting standards. Suggestions are welcome through GitHub Issues or Pull Requests. Feedback email: `youngshuangxi@gmail.com`.

Before contributing, read [CONTRIBUTING.md](../CONTRIBUTING.md), [CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md), and [SECURITY.md](../SECURITY.md). Never attach patient data or other sensitive information to issues, pull requests, or emails.

## Citation and license

Copyright (c) 2026 Yang Kaikai from GMU.

Distributed under the [MIT License](../LICENSE). If this skill supports your research, use [`CITATION.cff`](../CITATION.cff) in the repository root for citation metadata.

