#!/usr/bin/env python3
"""Small repository-level validation for the bilingual Codex skill package."""

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
REQUIRED_REFERENCES = {
    "cox-and-competing-risks.md",
    "data-workflows.md",
    "modeling-patterns.md",
    "reproducible-reporting.md",
    "source-scope.md",
    "validation-and-performance.md",
    "workflow.md",
}
REQUIRED_SCRIPTS = {"clinical_model_checks.R", "data_contract_checks.R"}


def check_skill(language: str) -> list[str]:
    errors: list[str] = []
    skill = ROOT / language / "clinical-prediction-modeling-r"
    skill_md = skill / "SKILL.md"
    if not skill_md.is_file():
        errors.append(f"{language}: missing SKILL.md")
        return errors
    text = skill_md.read_text(encoding="utf-8")
    if not re.search(r"^name:\s*clinical-prediction-modeling-r\s*$", text, re.M):
        errors.append(f"{language}: invalid or missing name frontmatter")
    if not re.search(r"^description:\s*.+$", text, re.M):
        errors.append(f"{language}: missing description frontmatter")
    references = {p.name for p in (skill / "references").glob("*.md")}
    scripts = {p.name for p in (skill / "scripts").glob("*.R")}
    errors.extend(f"{language}: missing reference {x}" for x in sorted(REQUIRED_REFERENCES - references))
    errors.extend(f"{language}: missing script {x}" for x in sorted(REQUIRED_SCRIPTS - scripts))
    if not (skill / "agents" / "openai.yaml").is_file():
        errors.append(f"{language}: missing agents/openai.yaml")
    return errors


def main() -> int:
    errors = check_skill("zh-CN") + check_skill("en-US")
    for forbidden in (".DS_Store", ".Rhistory"):
        if any(ROOT.rglob(forbidden)):
            errors.append(f"forbidden metadata file present: {forbidden}")
    if errors:
        print("VALIDATION_FAILED")
        print("\n".join(f"- {e}" for e in errors))
        return 1
    print("VALIDATION_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
