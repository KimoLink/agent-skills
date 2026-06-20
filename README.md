# 奇梦智能体技能包

面向 Codex、Claude Code、Trae 和通用 `.agents` 目录的全局规则与 skills。安装后即可获得中文协作规则、Git 提交收口、工程评审、专利评审和中文文档处理能力。

## 快速安装

Windows PowerShell：

```powershell
irm https://raw.githubusercontent.com/KimoLink/agent-skills/master/install.ps1 | iex
```

Linux、macOS 或 Git Bash：

```sh
curl -fsSL https://raw.githubusercontent.com/KimoLink/agent-skills/master/install.sh | sh
```

脚本会交互选择安装目标：

- Codex：`~/.codex/AGENTS.md`、`~/.codex/skills/`
- Claude Code：`~/.claude/CLAUDE.md`、`~/.claude/skills/`
- 通用目录：`~/.agents/AGENTS.md`、`~/.agents/skills/`
- Trae：`~/.trae/user_rules.md` 个人规则、`~/.trae/skills/`
- 全部目标：同时写入以上位置

覆盖已有规则或同名 skill 前会自动备份。规则文件备份为同目录 `.bak.<timestamp>`；旧 skill 目录备份到目标根目录的 `.skill-backups/skills/`。不同名 skill 不会被删除。

直接执行远程脚本前，建议先下载脚本查看内容。

## 非交互安装

PowerShell：

```powershell
irm https://raw.githubusercontent.com/KimoLink/agent-skills/master/install.ps1 -OutFile install.ps1
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Target codex -Yes
```

sh：

```sh
curl -fsSL https://raw.githubusercontent.com/KimoLink/agent-skills/master/install.sh -o install.sh
sh install.sh --target codex --yes
```

远程传参：

```sh
curl -fsSL https://raw.githubusercontent.com/KimoLink/agent-skills/master/install.sh | sh -s -- --target codex --yes
```

常用参数：

- `codex`、`claude`、`agents`、`trae`、`all`：安装目标。
- `-DryRun` / `--dry-run`：只查看计划写入内容。
- `-Ref <ref>` / `--ref <ref>`：指定分支或 tag，默认 `master`。
- `-Yes` / `--yes`：非交互确认覆盖。

锁定版本示例：

```powershell
irm https://raw.githubusercontent.com/KimoLink/agent-skills/v0.1.0/install.ps1 -OutFile install.ps1
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Ref v0.1.0 -Target codex -Yes
```

```sh
curl -fsSL https://raw.githubusercontent.com/KimoLink/agent-skills/v0.1.0/install.sh | sh -s -- --ref v0.1.0 --target codex --yes
```

## 使用

安装到 Codex 后，`AGENTS.md` 会作为全局规则生效；安装到 Trae 后，`user_rules.md` 会作为个人规则文件写入，skills 会写入 `~/.trae/skills/`。skills 可用 `$skill-name` 触发。

常用入口：

- `$git-commit`：检查、拆分、暂存并提交 Git 变更。
- `$review-engineering`：通用工程评审。
- `$review-nuxt`、`$review-nest`、`$review-dotnet`、`$review-qt`、`$review-rust`、`$review-unity`、`$review-unreal`：专项工程评审。
- `$patent-review`：评审专利交底书、发明点和申请前技术材料。
- `$de-ai`：降低中文专业文本的 AI 腔和模板化表达。
- `$fix-punctuation`：规范中文和中英混排标点。

全局规则重点：

- 默认中文回复，结论必须区分已完成、未完成和未验证。
- 代码类任务先查证再动手，修改前尊重仓库格式和验证规则。
- 工程方案先识别约束和主链路，不为“架构完整”提前增加复杂度。
- 调试先建立证据链，沿真实执行链路定位，修复后针对原始问题回归验证。
- 提交前按仓库历史风格写清楚实际变更内容。

Claude Code 和其他工具是否支持相同的 `$skill-name` 触发方式，取决于对应工具自己的 skill 机制；本仓库只负责把规则和 skill 文件安装到约定目录。

## 目录

- `AGENTS.md`：全局协作、工程、调试和开发规则。
- `skills/*/SKILL.md`：skill 触发条件、流程和硬性约束。
- `skills/*/agents/openai.yaml`：面向 OpenAI/Codex 展示的名称、说明和默认提示。
- `skills/review-engineering/stacks/*.md`：工程评审专项技术栈清单。
- `install.ps1`、`install.sh`：安装脚本。
- `tests/`：安装与 review skill 结构回归测试。
- `VERSION`：当前版本。

## 维护

- 修改 skill 时，同时检查 `SKILL.md` 和 `agents/openai.yaml`。
- 新增或调整 review 专项时，保持 `review-*` 薄入口，专项清单放在 `review-engineering/stacks/`。
- 修改安装备份逻辑后，运行安装脚本测试。
- 修改 review 结构后，运行 `tests/review-skill-structure.Tests.ps1`。
- 不提交密钥、token、本地路径凭据、临时生成文件或个人私有 skill。
