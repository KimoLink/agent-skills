---
name: git-commit
description: Use when 用户要求提交、暂存并提交、修改最近提交、修正提交信息、拆分提交，或需要按目标仓库既有历史风格收口 Git 变更。
---

# Git 提交

## 目标

创建范围清楚、便于审查、符合仓库历史风格的 Git 提交。提交信息以当前 staged diff 为依据，正文只记录变更项；验证结果、环境缺口和执行过程放在最终回复。

## 核心规则

- 写 subject 前查看近期历史：`git log --format="%s" -n 20`。
- 暂存前查看工作树和变更：`git status --short`、`git diff --stat`，必要时查看目标文件 diff。
- 保留用户已有改动；用户明确要求时再处理回滚。
- 一个清晰逻辑单元优先一个提交；多个变更能独立理解和审查时再拆分。
- 近期 subject 是中文就写中文；近期是英文祈使句就按英文风格。
- 变更极小且一眼能懂时可只写 subject；其他情况用 body 写清具体变更。
- 暂存优先使用显式路径；用户要求“提交你修改的部分”时，按最小范围暂存，把无关并行改动留在工作树。
- 在需要沙箱审批的环境中，`git add`、`git commit`、`git commit --amend` 等写入 index 或 Git 对象的命令要提前申请审批。

## 工作流

1. 定位仓库根目录并检查状态。
   使用 `git rev-parse --show-toplevel`、`git status --short --branch`，说明当前分支状态和脏改动概况。

2. 查看近期提交风格。
   使用 `git log --format="%s" -n 20`，匹配语言、措辞、前缀习惯和 subject 长度；历史已经使用 Conventional Commits 时再沿用 Conventional Commits。

3. 检查变更集。
   使用 `git diff --stat` 和目标 diff 区分本次应提交的变更、用户已有改动和无关并行改动。若存在 submodule 变更，用 `git -C <submodule> status --short` 检查子模块内部状态。

4. 判断提交拆分。
   连贯 diff 优先收口成一个提交；核心代码、文档、生成产物、子模块指针更新等能独立审查时再拆分。

5. 有意暂存。
   使用 `git add <explicit paths>`。提交前运行 `git diff --cached --stat`，确认 staged diff 对应一个预期逻辑单元。

6. 基于 staged diff 写提交信息。
   Subject 说明具体变化并匹配仓库历史风格。Body 使用连续 bullet，只写 staged diff 支撑的具体变更；必要时可写 why、变更边界、排除项或兼容影响，但仍需落在变更本身或变更影响上。验证命令、检查通过状态、完成总结和过程记录放在最终回复。

7. 非交互提交。
   使用命令参数或 message 文件一次性写入提交信息。

8. 提交后复查。
   运行 `git log --format="%B" -n 1` 和 `git status --short --branch`，确认提交信息格式和剩余工作树状态。

## 修改最近提交

用户明确要修改最近提交时使用 amend。

- 修正最近提交信息前，先用 `git log --format="%h%n%B" -n 1` 查看原提交。
- 只调整 message 时，运行 `git commit --amend` 前保持 staged diff 为空。
- 需要把文件改动一起并入最近提交时，先检查 `git status --short`，确认这些改动属于该提交。
- amend 后运行 `git log --format="%B" -n 1` 和 `git status --short --branch` 复查结果。

## 提交信息

默认结构：

```text
<匹配仓库风格的提交标题>

- 具体变更一
- 具体变更二
- 必要的变更边界或兼容影响
```

正文要求：

- Body bullet 保持连续，中间无空行。
- Subject 写清对象和变化，例如具体模块、功能、文档或资源。
- Body 提供 subject 之外的具体变更信息。
- Body 只写变更项；验证状态、检查结果、完成状态和过程总结放在最终回复。
- 每个结论都有 staged diff 支撑。

## PowerShell 提交命令

把所有 body bullet 放在同一个 `-m` 参数或同一个 message 文件中。Git 会把每个 `-m` 当成独立段落；统一放入一个 body 参数可以保持 bullet 连续。

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

引用转义不稳定时使用 message 文件：

```powershell
git commit -F path\to\commit-message.txt
```

使用 `-F` 前先检查文件内容；提交后清理临时提交信息文件。

## 提交前后检查

提交或 amend 前确认：

- Subject 语言和风格匹配 `git log --format="%s" -n 20`。
- Body 是一个连续 bullet 段落。
- 每条 bullet 都是 staged diff 支撑的变更事实。
- Body 呈现已完成的变更事实。
- 所有 body bullet 放在同一个提交正文段落。
- 验证命令、检查通过状态、任务完成总结或执行过程保留到最终回复。

提交或 amend 后检查：

```powershell
git log --format="%B" -n 1
git status --short --branch
```

如果提交信息需要修正，汇报前用 amend 收口。

## 子模块

- `git status --short` 显示子模块变更时，先进入子模块内部检查。
- 子模块内有需要提交的变更时，先按子模块自己的历史风格提交，再提交父仓库指针。
- 子模块变化是本次工作造成的偶发状态时，确认安全后只整理自己的偶发变更。

## 最终回复

汇报以下内容：

- 提交拆分理由。
- 准确的 commit subject。
- body 中使用的具体变更要点。
- 提交后运行的验证命令。
- 剩余工作树状态。
- 是否有子模块需要单独提交。
