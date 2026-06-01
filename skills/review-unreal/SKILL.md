---
name: review-unreal
description: Use when 用户要求对 Unreal Engine、UE、UE5、虚幻引擎、实时渲染、仿真演示、游戏、数字孪生或 Unreal 工具项目做工程级评审、资产治理审查、C++ 模块架构审查或 Unreal 工程质量审查；不要用于普通功能需求验收、演示效果评价、视觉效果评价或只检查某个运行 bug。
---

# Unreal 工程评审

## 定位

这是 `review-engineering` 的专项入口。它只负责在用户直接调用 `$review-unreal` 或项目明显命中该技术栈时，把通用工程评审基线和 Unreal 专项清单合并使用。

重点关注：Unreal 工程目录、C++ 模块边界、Build.cs、Content 资产治理、蓝图边界、配置、Cook/Package、自动化测试、Git LFS 和仓库治理。不做普通功能需求验收、业务规则评审、界面效果评价或单点 bug 排查。

## 使用方式

1. 先阅读并采用 `review-engineering/SKILL.md` 的通用工程基线、执行红线、问题定性和报告落地要求。
2. 再读取 `review-engineering/stacks/unreal.md`，只合并其中与当前仓库事实相关的专项检查项。
3. 最终只输出一次评审、一次结论和一份 `docs/reviews/` 报告；不要分别输出通用评审和专项评审两套结果。
4. 如果仓库是混合技术栈，先按 `review-engineering` 分出子系统，再按实际命中的 stacks 组合检查。

## 报告边界

- 评审结论必须能落到文件、目录、配置、命令输出或仓库状态。
- 命令无法执行时说明阻断原因，不把未验证状态写成通过。
- 同日复评优先合并进已有 `docs/reviews/YYYY-MM-dd-*.md` 报告结构。
