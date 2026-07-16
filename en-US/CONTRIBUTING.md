# Contributing

1. Open an issue before substantial changes.
2. Keep `SKILL.md` concise and move detail into one-level `references/` files.
3. Preserve reproducibility rules: explicit time zero, event coding, factor references, missing-data decisions, validation boundaries, and package versions.
4. Do not add patient data, private paths, model outputs, textbook scans, or copied copyrighted passages.
5. Before a pull request, run `python scripts/validate_skill.py` from the repository root and parse the R check scripts in both language versions.
