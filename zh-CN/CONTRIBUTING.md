# 贡献指南

1.  大幅修改前先创建 issue。
2.  保持 `SKILL.md` 简洁，将详细内容放入一级 `references/` 文件。
3.  保留可复现原则：明确 time zero、事件编码、因子参考水平、缺失处理、验证边界和包版本。
4.  不得加入患者数据、个人绝对路径、模型结果、教材扫描件或受版权保护的逐字内容。
5.  提交 pull request 前运行仓库根目录的 `python scripts/validate_skill.py`，并解析两个语言版本的 R 检查脚本。
