---
name: git-commit
description: Use when 用户要求提交、暂存并提交、修改最近提交、修正提交信息、拆分提交，或需要按目标仓库既有历史风格收口 Git 变更。
---

# Git 提交

## 概览

创建范围清楚、便于审查、符合仓库历史风格的 Git 提交。提交信息必须基于实际 staged diff 编写，不能套模板、不能只凭任务描述猜。

## 核心规则

- 写 subject 前必须看历史：`git log --format="%s" -n 20`。
- 暂存前必须看变更：`git status --short`、`git diff --stat`，必要时看目标文件 diff。
- 不要回滚用户改动，除非用户明确要求。
- 一个清晰逻辑单元优先一个提交；只有多个变更能独立理解和审查时才拆分。
- 匹配仓库主导语言和风格。近期 subject 是中文就写中文；近期是英文祈使句就按英文风格。
- 默认不要只写 subject。除非变更极小且一眼能懂，否则 body 要写清楚改了什么。
- 显式路径可行时，不要用宽泛暂存。
- 如果用户要求“提交你修改的部分”，默认做最小范围提交；优先使用显式路径或交互式暂存，避免带入无关并行改动。
- 在需要沙箱审批的环境中，`git add`、`git commit`、`git commit --amend` 等写入 index 或 Git 对象的命令要提前申请审批；不要先故意跑出 `.git/index.lock` 权限失败。

## 工作流

1. 定位仓库根目录并检查状态。
   使用 `git rev-parse --show-toplevel`、`git status --short --branch`，说明当前分支是否 ahead、是否已有脏改动。

2. 查看近期提交风格。
   使用 `git log --format="%s" -n 20`。匹配语言、措辞、前缀习惯和 subject 长度。不要强行使用 Conventional Commits，除非历史已经这么写。

3. 检查变更集。
   使用 `git diff --stat` 和目标 diff。区分本次应提交的变更和用户已有无关变更。若存在 submodule 变更，用 `git -C <submodule> status --short` 检查子模块内部状态。

4. 判断是否拆分提交。
   如果 diff 是一个连贯单元，优先一个提交。核心代码、文档、生成产物、子模块指针更新等能独立审查时再拆分。

5. 有意暂存。
   使用 `git add <explicit paths>`。提交前运行 `git diff --cached --stat`，确认 staged diff 正好对应一个预期逻辑单元。

6. 基于 staged diff 写提交信息。
   Subject：模仓历史风格，说明具体变化。
   Body：用连续 bullet 写改了什么；必要时补 why、边界、排除项、兼容影响或验证结果。

7. 非交互提交。
   使用下方安全命令模式。不要进入交互式编辑器。

8. 验证结果。
   运行 `git log --format="%B" -n 1` 和 `git status --short --branch`。确认实际提交信息格式正确，并说明剩余工作树状态。

## 修改最近提交

只在用户明确要修改最近提交时使用 amend。

- 如果用户只要求修正最近提交信息，先用 `git log --format="%h%n%B" -n 1` 查看原提交。
- 如果只是 message 错误，运行 `git commit --amend` 时不要暂存新的文件改动。
- 如果需要把文件改动一起并入最近提交，先检查 `git status --short`，并确认这些改动确实属于该提交。
- amend 后必须用 `git log --format="%B" -n 1` 和 `git status --short --branch` 验证。

## 提交信息格式

默认结构：

```text
<匹配仓库风格的提交标题>

- 具体变更一
- 具体变更二
- 必要的边界、兼容说明或验证结果
```

Body bullet 必须连续，中间不要空行。

避免：

- `Update code`、`Refactor codebase`、`Fix issues`、`完善`、`处理问题` 这类看不出对象和变化的泛化 subject。
- 中文历史仓库里写英文示例，或英文历史仓库里突然写中文。
- body 只是重复 subject，没有增加具体信息。
- 写 staged diff 或当前验证输出不支持的结论。
- 没有在当前会话实际运行验证命令，却写“已验证”“测试通过”。

## PowerShell 安全命令

不要把每条 body bullet 分别作为一个 `git commit -m` 参数。Git 会把每个 `-m` 当成独立段落，导致 bullet 之间出现空行。

简单 body：

```powershell
git commit -m "提交标题" -m "- 第一条正文`n- 第二条正文`n- 第三条正文"
```

包含引号或复杂标点时：

```powershell
$body = @'
- 第一条正文
- 第二条正文
- 第三条正文
'@
git commit -m "提交标题" -m $body
```

Amend 使用同一规则：

```powershell
$body = @'
- 第一条正文
- 第二条正文
- 第三条正文
'@
git commit --amend -m "提交标题" -m $body
```

如果当前环境的引用转义不稳定，可以使用 message 文件：

```powershell
git commit -F path\to\commit-message.txt
```

使用 `-F` 前必须检查文件内容；不要把临时提交信息文件留在仓库里。

## 提交前后检查

提交或 amend 前检查：

- Subject 语言和风格匹配 `git log --format="%s" -n 20`。
- Body 是一个连续 bullet 段落。
- 每条 bullet 都是事实，能被 staged diff 支撑。
- 没有 bullet 暗示未完成或未执行的工作。
- 没有使用每条 bullet 一个 `-m` 的写法。
- 验证 bullet 只写当前会话实际运行且通过的命令。

提交或 amend 后检查：

```powershell
git log --format="%B" -n 1
git status --short --branch
```

如果 body bullet 之间有空行、信息不准确、语言或风格错误，必须在汇报前立即 amend 修正。

## 子模块

- 如果 `git status --short` 显示子模块变更，先进入子模块内部检查。
- 如果子模块内有需要提交的变更，先按子模块自己的历史风格提交，再提交父仓库指针。
- 如果子模块变化是本次工作造成的偶发状态，确认安全后只恢复自己的偶发变更。

## 常见误用红线

- 没看历史就写 subject。
- 没看 staged diff 就写 body。
- 用 `git add .` 把无关用户改动一起提交。
- 把验证命令、环境缺口或过程噪音硬塞进提交日志；这些通常放交付说明，除非仓库规范要求写入 message。
- 因为提交很急就跳过提交后 `git log` 和 `git status` 验证。

## 最终回复

汇报以下内容：

- 提交拆分理由。
- 准确的 commit subject。
- body 中使用的具体要点。
- 提交后运行的验证命令。
- 剩余工作树状态。
- 是否有子模块需要单独提交。
