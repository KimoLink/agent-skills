---
name: review-nest
description: Use when 用户要求对 Nest、NestJS、Node.js API 服务、后端管理服务、BFF、微服务或服务端 TypeScript 项目做工程级评审、架构规范审查、模块边界审查或后端工程质量审查；不要用于普通接口功能验收、业务规则评审或只检查某个 bug。
---

# Nest 后端工程评审

## 定位

这是 NestJS/Node.js 后端项目的工程级评审流程。它是 `review-engineering` 的 Nest 专项版本，重点看服务端工程体系、架构边界、规范执行和长期维护风险，不做业务功能验收。

评审对象包括 Nest 模块组织、controller/service/provider 分层、DTO 和接口契约、配置和环境变量、数据库访问、鉴权授权、异常处理、日志观测、包管理、质量门禁、仓库治理、测试体系、文档同步和提交规范。

**REQUIRED BASELINE:** 先阅读并采用 `review-engineering` 的通用工程基线。

使用本 skill 时，必须把 `review-engineering` 的通用工程基线和本 skill 的 Nest 专项清单合并使用，最终只输出一次评审、一次结论和一份报告。本 skill 只补充服务端专项要求，不能跳过或降低通用工程基线。

## 评审原则

- 使用中文输出。
- 不写模板腔、口号和对立转折式套话。
- 先确认评审依据层级：`review-engineering` 的通用硬性工程基线、本 skill 的 Nest 专项基线、用户或部门通用要求、项目已有规范、仓库事实、工具配置、CI 或团队约定。报告里要写清楚依据来自哪里。
- 项目 `AGENTS.md`、README 或现场文档不能降低通用硬性工程基线和本 skill 的专项硬性要求；如果项目规范与基线冲突，应记录为“项目规范与工程基线冲突”，而不是按项目规范放行。
- 项目规范可以补充、细化或提高要求；若项目缺少规范，只能定性为“规范缺失带来的工程风险”或“建议补充规范”，不要写成违反既定规范。
- 问题定性要区分五类：违反硬性工程基线、项目规范与工程基线冲突、违反项目已确认规范、规范缺失导致风险、可选优化建议。
- 结论必须有文件、目录、配置、命令输出或仓库状态支撑。
- 不把服务能启动、接口能返回当成工程合格。
- 能检查的命令要检查；不能检查时说明原因。
- 格式检查只做 check，不自动格式化全仓。
- 构建、类型检查、lint 出现 warning 要作为风险记录。

## 先确认项目事实

读取：

- `AGENTS.md`、README、接口文档、部署文档、架构文档。
- `package.json`、`bun.lock` / `pnpm-lock.yaml` / `package-lock.json` / `yarn.lock`。
- `nest-cli.json`、`tsconfig*.json`、`eslint.config.*`、`.eslintrc*`、`.prettierrc`、`.editorconfig`。
- `.env.example`、配置模块、Dockerfile、compose 文件、CI 配置。
- `.gitignore`、`.gitattributes`、Git LFS 规则、提交规范文档。
- `src/`、`test/`、`prisma/`、`migrations/`、`scripts/`、`libs/`、`apps/`。

核对：

- 包管理器是否单一。
- Nest 版本、Node 版本、TypeScript 版本和文档是否一致。
- 项目是单体、模块化单体、BFF、微服务还是 monorepo。
- 数据库、缓存、消息队列、对象存储、第三方服务接入是否有清晰边界。
- lint、format check、typecheck、build、test 是否有清晰入口。

## 核心检查项

### Nest 模块和分层边界

检查：

- `AppModule` 是否只负责根组合，不承担业务逻辑。
- 业务模块是否按领域划分，而不是按 controller、service、dto 等技术分层平铺全局目录。
- controller 是否只处理 HTTP/传输层输入输出，不直接写数据库、不拼复杂业务流程。
- service 是否职责清晰，避免变成跨领域事务脚本。
- provider、guard、pipe、interceptor、filter 是否放在合理目录，并通过模块依赖显式暴露。
- 模块之间是否存在循环依赖、随意导出 provider、全局模块滥用。
- monorepo 中 `apps/`、`libs/`、共享包和业务服务边界是否清楚。

### DTO、校验和接口契约

检查：

- 请求 DTO、响应 DTO、实体、数据库模型、ViewModel 是否分清。
- 是否使用 class-validator、Zod 或等价机制做输入校验。
- 是否有全局 validation pipe，白名单、转换、未知字段处理是否明确。
- OpenAPI/Swagger、接口文档或契约测试是否和代码一致。
- 错误响应结构是否统一，不能在 controller 中随意返回不同格式。
- 分页、排序、过滤、ID、时间、枚举、状态字段是否有统一约定。

### 配置、环境变量和安全边界

检查：

- 配置是否集中在 ConfigModule、配置工厂或等价模块中。
- `.env.example` 是否覆盖必需变量，不包含真实密钥。
- 是否在代码中硬编码数据库地址、Token、外部服务 URL、路径、包安装环境配置或个人环境。
- 环境变量是否有类型和校验。
- 鉴权、授权、租户、角色、审计等横切能力是否集中处理。
- CORS、限流、上传大小、cookie、session、JWT、CSRF、helmet 等安全配置是否有明确入口。

### 数据库、事务和外部服务

检查：

- ORM/查询层是否集中管理，例如 Prisma、TypeORM、MikroORM、Drizzle。
- migration、schema、seed、fixture 是否有明确目录和执行说明。
- service 是否直接散落原始 SQL 或外部 API 调用。
- 事务边界是否显式，跨领域写操作是否有一致处理方式。
- 数据库实体、领域模型、DTO 是否互相污染。
- 外部服务 client 是否集中封装，是否具备超时、重试、错误映射和可测试替身。

### 日志、异常和观测

检查：

- 全局 exception filter 是否统一错误格式和日志记录。
- logger 是否有统一抽象，避免 `console.log` 散落。
- 请求日志、审计日志、业务日志、错误日志是否区分。
- 日志中是否可能输出 token、密码、身份证、手机号等敏感数据。
- metrics、health check、readiness/liveness、trace id 是否有明确入口。

### 包管理、仓库治理和依赖治理

检查：

- 包管理器是否单一。在当前用户环境中，Node.js 项目默认必须使用 Bun；不要主动使用 npm。Bun 项目不应出现 `package-lock.json`、`pnpm-lock.yaml`、`yarn.lock`。
- 锁文件是否与 `package.json` 一致。
- Node.js 项目的包安装环境应由个人环境或 CI 环境配置处理。项目级 `.npmrc`、`bunfig.toml` 不应提交包源地址、scope 源、代理、认证、证书路径或其他只属于某一运行环境的配置。
- 是否引入重复框架、重复校验库、重复 HTTP client、重复日志库。
- `.gitignore` 是否覆盖 `node_modules/`、`dist/`、coverage、日志、`.env`、临时文件、上传样例、数据库本地文件。
- `.gitignore` 是否误忽略应提交内容，例如锁文件、migration、schema、接口契约、测试 fixture。
- `.gitattributes` 是否处理换行规范、二进制资源和 LFS 规则。
- Git LFS 是否只用于确实需要版本化的大体积样本数据、模型、文档附件或二进制资源；不要把源码、配置、锁文件、migration、普通 JSON 放进 LFS。

### 代码格式化和质量配置

检查：

- ESLint、Prettier、`.editorconfig`、TypeScript 配置是否一致。
- 是否存在 `format:check` 或 `prettier --check .`，不要用 `format:fix` 冒充格式检查。
- lint 是否覆盖 TypeScript、测试文件、配置文件和 Nest 常见反模式。
- typecheck 是否独立可执行，不能只依赖 build 顺带发现类型问题。
- 是否存在多套冲突配置，例如 ESLint flat config、旧 `.eslintrc`、IDE 配置互相覆盖。
- `strict`、`noImplicitAny`、路径别名、module resolution 是否符合项目复杂度。

### 静态检查、格式检查、类型检查、构建和测试

优先查 `package.json` scripts，再按项目事实运行或记录缺失：

- 依赖安装：默认使用 Bun，不混用。
- 静态检查：`bun run lint`。
- 格式检查：优先 `format:check`、`prettier --check .`。
- 类型检查：`tsc --noEmit` 或项目脚本。
- 构建：`bun run build`。warning 需要记录。
- 测试：单元测试、集成测试、e2e 测试、契约测试。

如果只有 `format:fix` 没有 format check，记录为质量门禁缺失。  
如果 lint、typecheck、test 脚本缺失，记录为验证入口不完整。  
如果命令无法执行，说明原因，不写成通过。

### 测试体系

检查：

- 单元测试是否覆盖 service、pipe、guard、filter、纯函数和复杂业务规则。
- 集成测试是否覆盖模块组合、数据库访问、事务和外部依赖替身。
- e2e 测试是否覆盖关键 API 路由、鉴权、错误响应和权限边界。
- 测试数据、fixture、mock、容器依赖是否有固定目录。
- 测试是否污染真实数据库、外部服务或本地环境。
- 测试日志、coverage、临时数据库和上传文件是否进入专用目录并被忽略。

### 命名、代码规范和业务术语

检查：

- module、controller、service、provider、DTO、entity、repository、guard、pipe、interceptor、filter 命名是否统一。
- 文件命名是否符合项目约定，例如 `*.module.ts`、`*.controller.ts`、`*.service.ts`、`*.dto.ts`。
- 业务术语是否统一，避免旧项目名、模板名、错误业务词残留。
- 状态枚举、错误码、权限标识、事件名、队列名、配置键是否系统化。
- `any`、类型断言、动态对象、全局变量是否被限制在明确边界。

### Git 历史、文档和提交规范

检查：

- Git 历史中是否有构建产物、日志、上传样例、本地数据库、密钥或大体积二进制直接进入普通 Git 对象。
- Git LFS、`.gitignore`、`.gitattributes` 是否和当前后端产物、测试产物、样本数据匹配。
- README、AGENTS、部署文档、接口文档是否与当前代码一致。
- 命令说明是否真实可执行。
- Git 提交信息是否符合正式项目要求，并按 `review-engineering` 与 `/git-commit` 标准检查 subject、body、语言、逻辑单元、历史可追溯性和是否夹带过程噪音。

## 问题分级

- 高：模块边界失控、controller 直连数据库、配置和密钥治理失效、鉴权授权散落、构建或类型检查 warning、lint/typecheck/build/test 不可用、严重仓库污染、错误提交大体积产物或敏感配置。
- 中：service 职责过重、DTO/实体/响应模型混用、异常格式不统一、日志散落、格式化配置冲突、gitignore 或 LFS 规则不完整、文档漂移、提交规范缺失。
- 低：局部命名不一致、个别文件位置不理想、少量配置说明不清。

只写真实问题。没有证据不要写。

## 报告结构和表达要求

沿用 `review-engineering` 的报告结构、问题定性和表达要求，报告标题用 `# <项目名>后端工程评审报告`。

必须按 `review-engineering` 的报告落地规则，在项目根目录 `docs/reviews/` 下生成或合并 `YYYY-MM-dd-主题描述.md` 评审报告。

评审范围写清楚：本次只评审 Nest 后端工程体系、架构规范和风险，不评价功能需求完成度。检查情况中列出已执行或无法执行的 lint、format check、typecheck、build、test 命令及结果。
