# Source scope, educational provenance, and version correction

This skill is an original synthesis based on the user-provided Chinese textbook *Practical R Clinical Prediction Modeling* (Peng Xianzhen, 2022) and its companion materials. The source textbook and code were not copied into this skill.

The scope covers:

- linear regression, association, residuals, heteroscedasticity, and collinearity;
- binary, multinomial, ordinal, and conditional Logistic regression with OR/CI;
- Kaplan-Meier, log-rank, Cox regression, and proportional-hazards diagnostics;
- CIF, Gray tests, and Fine-Gray `crr()`;
- univariable/stepwise/LASSO/random-forest/best-subset/PCA discussions with explicit safeguards against selection bias;
- nomograms, calibration, C-index, ROC, DCA, NRI/IDI, cross-validation, and bootstrap validation.

The skill also incorporates transferable workflow principles from *R for Data Science* (Wickham and Grolemund) without reproducing its prose, figures, or complete code: visual data audits, typed import, project-relative paths, keys and join cardinality, string cleaning, factors and reference levels, date/time handling, functional checks, tidy model outputs, and knitted R Markdown/Quarto research records.

The teaching sources reflect older package ecosystems. Confirm current function arguments and returned objects against installed package documentation and primary sources, including `readxl`, `readr`, `dplyr` join relationships, tidymodels resampling/recipes, and `renv`.

This repository distributes original methodological guidance and does not redistribute copyrighted textbook scans, figures, or textbook source code.
