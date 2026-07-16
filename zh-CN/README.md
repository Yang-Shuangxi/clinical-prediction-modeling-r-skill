# R 临床预测模型 Codex Skill

这是一个面向医学研究的 Codex skill，用于在 R 中构建、验证和报告可复现的临床预测模型。内容覆盖数据契约、数据导入、Logistic 回归、Cox 比例风险模型、竞争风险、校准、判别、临床效用和透明研究报告。

## 目录内容

本目录中的 `clinical-prediction-modeling-r/` 是可安装的中文 skill，包含：

- `SKILL.md`：核心工作流和触发规则；
- `agents/openai.yaml`：Codex 界面元数据；
- `references/`：按需读取的数据、建模、Cox、验证和可复现性参考；
- `scripts/`：R 数据契约和临床模型结构检查函数。

## 使用范围

该 skill 面向研究级、可复现的临床预测工作流，不提供个体诊疗建议，也不会在缺少外部验证、校准、临床效用评估和治理证据时宣称模型可以临床部署。

## 使用

将本目录下的 `clinical-prediction-modeling-r/` 作为 skill 安装或复制到 Codex skills 目录。请求中可以使用：

``` text
使用 $clinical-prediction-modeling-r，构建并验证一个 Cox 临床预测模型。
```

## 归属与许可证

Copyright (c) 2026 Yang Kaikai from GMU。项目采用 [MIT License](../LICENSE)。

本 skill 包含原创的方法学整理和权威资料链接，不重新分发来源教材正文、扫描件或完整教材代码。
