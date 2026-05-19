# 奇梦智能体技能包

奇梦智能体技能包保存面向 AI 编程助手的用户全局规则和 skills，用于统一日常协作方式、文档处理、提交收口和工程评审流程。

不同工具的配置目录和指令文件约定并不相同；安装脚本会按目标工具写入对应位置，也可以安装到通用 `.agents` 目录。

## 一键安装

Windows PowerShell：

```powershell
irm https://raw.githubusercontent.com/KimoLink/.agents/master/install.ps1 | iex
```

Linux、macOS 或 Git Bash：

```sh
curl -fsSL https://raw.githubusercontent.com/KimoLink/.agents/master/install.sh | sh
```

脚本会进入交互式选择：

- Codex：写入 `~/.codex/AGENTS.md` 和 `~/.codex/skills/`
- Claude Code：写入 `~/.claude/CLAUDE.md` 和 `~/.claude/skills/`
- 通用目录：写入 `~/.agents/AGENTS.md` 和 `~/.agents/skills/`
- 全部目标：同时写入以上三个位置

发现已有规则文件或同名 skill 时，脚本会提示是否覆盖，默认回车即覆盖。覆盖前会把旧文件或旧目录备份为 `.bak.<timestamp>`；目标目录里其他不同名 skill 不会被删除。

直接执行远程脚本前，建议先下载脚本查看内容，再执行。

## 非交互安装

PowerShell：

```powershell
irm https://raw.githubusercontent.com/KimoLink/.agents/master/install.ps1 -OutFile install.ps1
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Target codex -Yes
```

sh：

```sh
curl -fsSL https://raw.githubusercontent.com/KimoLink/.agents/master/install.sh -o install.sh
sh install.sh --target codex --yes
```

远程执行时也可以传参：

```sh
curl -fsSL https://raw.githubusercontent.com/KimoLink/.agents/master/install.sh | sh -s -- --target codex --yes
```

可用目标为 `codex`、`claude`、`agents`、`all`。使用 `-DryRun` 或 `--dry-run` 可查看计划写入内容但不落盘。

需要锁定版本时，使用 tag 地址并显式指定 ref：

```powershell
irm https://raw.githubusercontent.com/KimoLink/.agents/v0.1.0/install.ps1 -OutFile install.ps1
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Ref v0.1.0
```

```sh
curl -fsSL https://raw.githubusercontent.com/KimoLink/.agents/v0.1.0/install.sh | sh -s -- --ref v0.1.0
```

## 使用方式

安装到 Codex 后，`AGENTS.md` 会作为全局指令生效，`skills/` 下的 skill 使用 `$` 触发，例如：

- `$git-commit`：收口 Git 变更。
- `$review-engineering`：做通用工程评审。
- `$review-nuxt`、`$review-nest`、`$review-unity`、`$review-unreal`、`$review-qt`、`$review-dotnet`、`$review-rust`：做专项工程评审。
- `$de-ai` 或 `$fix-punctuation`：处理中文文档。

Claude Code 和其他工具是否支持相同的 `$skill-name` 调用方式，取决于对应工具自己的 skill 机制；本仓库只负责把规则和 skill 文件安装到约定目录。

## 目录结构

- `VERSION`：当前发布版本。
- `install.ps1`：Windows PowerShell 一键安装脚本。
- `install.sh`：Linux、macOS 和 Git Bash 一键安装脚本。
- `AGENTS.md`：用户全局规则，覆盖中文回复、任务拆分、提交判断和开发验证要求。
- `skills/*/SKILL.md`：具体 skill 的触发条件、流程和硬性约束。
- `skills/*/agents/openai.yaml`：面向 OpenAI/Codex 展示的名称、说明和默认提示。

## 当前 skills

- `de-ai`：降低中文专业文本的 AI 腔和模板化表达。
- `fix-punctuation`：规范中文和中英混排文本标点，同时保护代码、配置和公式。
- `git-commit`：按仓库历史风格检查、暂存、拆分并提交 Git 变更。
- `review-engineering`：通用工程评审基线，供所有专项工程评审合并采用。
- `review-nest`：NestJS/Node.js 后端工程专项评审。
- `review-nuxt`：Nuxt/Vue 前端工程专项评审。
- `review-dotnet`：C#/.NET、ASP.NET Core 和桌面端工程专项评审。
- `review-qt`：Qt Widgets/QML/C++ 桌面端工程专项评审。
- `review-rust`：Rust 后端、CLI、库和 workspace 工程专项评审。
- `review-unity`：Unity 工程、资源和脚本架构专项评审。
- `review-unreal`：Unreal Engine 工程、C++ 模块和资产治理专项评审。

## 维护规则

- 修改 skill 时同时检查 `SKILL.md` 和对应 `agents/openai.yaml` 是否一致。
- 评审类专项 skill 必须结合 `review-engineering` 的通用工程基线。
- Git 提交信息默认使用中文，并写清楚实际变更内容。
- 不把密钥、token、本地路径凭据或临时生成文件提交进仓库。
