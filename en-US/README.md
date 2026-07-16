# Clinical Prediction Modeling in R — Codex Skill

This Codex skill supports research-grade, reproducible clinical prediction modeling in R. It covers data contracts, typed data import, Logistic regression, Cox proportional-hazards models, competing risks, calibration, discrimination, clinical utility, validation, and transparent reporting.

## Contents

The `clinical-prediction-modeling-r/` directory is the installable English skill and contains:

- `SKILL.md`: core workflow and triggering guidance;
- `agents/openai.yaml`: Codex UI metadata;
- `references/`: on-demand guidance for data workflows, modeling, Cox/competing risks, validation, and reproducibility;
- `scripts/`: R functions for data-contract and clinical-model structural checks.

## Scope

This skill is intended for research-grade, reproducible clinical prediction workflows. It does not provide individual medical advice and does not claim clinical deployability without appropriate external validation, calibration, clinical utility assessment, and governance.

## Usage

Install or copy `clinical-prediction-modeling-r/` into a Codex skills directory. A typical request is:

```text
Use $clinical-prediction-modeling-r to build and validate a Cox clinical prediction model.
```

## Attribution and license

Copyright (c) 2026 Yang Kaikai from GMU. Distributed under the [MIT License](../LICENSE).

The skill contains original methodological synthesis and links to authoritative documentation; it does not redistribute source textbook pages, scans, or complete textbook code.
