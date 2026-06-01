---
name: review-nest
description: Use when 用户要求对 Nest、NestJS、Node.js API 服务、后端管理服务、BFF、微服务或服务端 TypeScript 项目做工程级评审、架构规范审查、模块边界审查或后端工程质量审查；不要用于普通接口功能验收、业务规则评审或只检查某个 bug。
---

# NestJS 后端工程评审

## 定位

这是 `review-engineering` 的专项入口。它只负责在用户直接调用 `$review-nest` 或项目明显命中该技术栈时，把通用工程评审基线和 NestJS 专项清单合并使用。

重点关注：模块边界、依赖注入、controller/service/repository 分层、配置与密钥、鉴权授权、错误处理、数据库访问、测试体系和部署治理。不做普通功能需求验收、业务规则评审、界面效果评价或单点 bug 排查。

## 使用方式

1. 先阅读并采用 `review-engineering/SKILL.md` 的通用工程基线、执行红线、问题定性和报告落地要求。
2. 再读取 `review-engineering/stacks/nest.md`，只合并其中与当前仓库事实相关的专项检查项。
3. 最终只输出一次评审、一次结论和一份 `docs/reviews/` 报告；不要分别输出通用评审和专项评审两套结果。
4. 如果仓库是混合技术栈，先按 `review-engineering` 分出子系统，再按实际命中的 stacks 组合检查。

## 报告边界

- 评审结论必须能落到文件、目录、配置、命令输出或仓库状态。
- 命令无法执行时说明阻断原因，不把未验证状态写成通过。
- 同日复评优先合并进已有 `docs/reviews/YYYY-MM-dd-*.md` 报告结构。
