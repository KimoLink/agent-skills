# 用户全局规则与技能库

这个仓库保存面向 AI 编程助手的用户全局规则和 skills，用于统一日常协作方式、文档处理、提交收口和工程评审流程。

Claude Code、Cursor、Codex 等工具的配置目录和指令文件约定并不相同；这个仓库只说明这里维护的用户全局规则和技能库。

## 目录结构

- `AGENTS.md`：用户全局规则，覆盖中文回复、任务拆分、提交判断、Node.js 和 Rust 验证要求。
- `skills/*/SKILL.md`：具体 skill 的触发条件、流程和硬性约束。
- `skills/*/agents/openai.yaml`：面向 OpenAI/Codex 展示的名称、说明和默认提示。

## 使用说明

在读取这套用户全局配置的工具中，`AGENTS.md` 会作为全局指令生效，`skills/` 下的 skill 可通过名称触发，例如：

- 使用 `$git-commit` 收口 Git 变更。
- 使用 `$review-engineering` 做通用工程评审。
- 使用 `$review-nuxt`、`$review-nest`、`$review-unity` 做专项工程评审。
- 使用 `$de-ai` 或 `$fix-punctuation` 处理中文文档。

## 当前 skills

- `de-ai`：降低中文专业文本的 AI 腔和模板化表达。
- `fix-punctuation`：规范中文和中英混排文本标点，同时保护代码、配置和公式。
- `git-commit`：按仓库历史风格检查、暂存、拆分并提交 Git 变更。
- `review-engineering`：通用工程评审基线，所有专项工程评审前置使用。
- `review-nest`：NestJS/Node.js 后端工程专项评审。
- `review-nuxt`：Nuxt/Vue 前端工程专项评审。
- `review-unity`：Unity 工程、资源和脚本架构专项评审。

## 维护规则

- 修改 skill 时同时检查 `SKILL.md` 和对应 `agents/openai.yaml` 是否一致。
- 评审类专项 skill 必须先引用 `review-engineering` 的通用工程基线。
- Git 提交信息默认使用中文，并写清楚实际变更内容。
- 不把密钥、token、本地路径凭据或临时生成文件提交进仓库。