# Contributing / 贡献指南

## English

1. Open an issue before substantial changes.
2. Keep `SKILL.md` concise and move detailed material into one-level `references/` files.
3. Preserve reproducibility rules: explicit time zero, event coding, factor references, missing-data decisions, validation boundaries, and package versions.
4. Do not add patient data, private paths, model outputs, textbook scans, or copied copyrighted passages.
5. Run `python scripts/validate_skill.py` and parse both R check scripts before submitting a pull request.

## 中文

1. 大幅修改前先创建 issue。
2. 保持 `SKILL.md` 简洁，将详细内容放入一级 `references/` 文件。
3. 保留可复现原则：明确 time zero、事件编码、因子参考水平、缺失处理、验证边界和包版本。
4. 不得加入患者数据、个人绝对路径、模型结果、教材扫描件或受版权保护的逐字内容。
5. 提交 pull request 前运行 `python scripts/validate_skill.py`，并解析两个 R 检查脚本。
