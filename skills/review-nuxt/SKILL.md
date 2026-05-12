---
name: review-nuxt
description: Use when 用户要求对 Nuxt、Vue、SPA 或 Web 前端项目做工程级评审、架构规范审查、组件体系审查、主题样式体系审查或前端工程质量审查；不要用于普通页面功能验收、UI 喜好评价或只检查某个交互 bug。
---

# Nuxt 前端工程评审

## 定位

这是 Nuxt/Vue 前端项目的工程级评审流程。它是 `review-engineering` 的 Nuxt 专项版本，重点看前端工程体系、架构边界、规范执行和长期维护风险，不做业务功能验收。

评审对象包括 Nuxt 应用目录、页面与组件分层、状态与 API 边界、组件库基线、主题样式体系、包管理、质量门禁、仓库治理、测试与调试产物、文档同步和提交规范。

**REQUIRED SUB-SKILL:** Use `review-engineering` before this skill.

使用本 skill 时，必须先按 `review-engineering` 完成通用工程评审，再进入本 skill 的 Nuxt/Vue 专项检查。本 skill 只补充前端专项要求，不能跳过或降低通用工程基线。

## 评审原则

- 使用中文输出。
- 不写模板腔、口号和对立转折式套话。
- 先确认评审依据层级：`review-engineering` 的通用硬性工程基线、本 skill 的 Nuxt/Vue 专项基线、用户或部门通用要求、项目已有规范、仓库事实、工具配置、CI 或团队约定。报告里要写清楚依据来自哪里。
- 项目 `AGENTS.md`、README 或现场文档不能降低通用硬性工程基线和本 skill 的专项硬性要求；如果项目规范与基线冲突，应记录为“项目规范与工程基线冲突”，而不是按项目规范放行。
- 项目规范可以补充、细化或提高要求；若项目缺少规范，只能定性为“规范缺失带来的工程风险”或“建议补充规范”，不要写成违反既定规范。
- 问题定性要区分五类：违反硬性工程基线、项目规范与工程基线冲突、违反项目已确认规范、规范缺失导致风险、可选优化建议。
- 结论必须有文件、目录、配置、命令输出或仓库状态支撑。
- 不评价页面是否“好看”，只评价组件、样式、主题、布局和交互实现是否形成工程体系。
- 不把页面能打开、构建能过当成工程合格。
- 能检查的命令要检查；不能检查时说明原因。
- 格式检查只做 check，不自动格式化全仓。
- 构建或类型检查出现 warning 要作为风险记录。

## 先确认项目事实

读取：

- `AGENTS.md`、README、项目设计文档。
- `package.json`、`bun.lock` / `pnpm-lock.yaml` / `package-lock.json` / `yarn.lock`。
- `nuxt.config.*`、`app.config.*`、`tsconfig.json`、`eslint.config.*`、`.prettierrc`、`.editorconfig`、`tailwind.config.*`、`assets/css/*`。
- `.gitignore`、`.gitattributes`、Git LFS 规则、CI 配置、测试配置。
- `app/`、`pages/`、`layouts/`、`components/`、`composables/`、`stores/`、`plugins/`、`middleware/`、`types/`、`utils/`。

核对：

- Nuxt 版本和目录约定是否一致。
- 包管理器是否单一。
- 文档中的技术栈、命令、目录、UI 规范是否和代码一致。
- 项目是否要求使用 Nuxt UI 或其他标准组件库。
- 当前是 SPA、SSR、SSG 还是混合模式。
- 格式化、lint、typecheck、build、test 是否有清晰的检查入口。

## 核心检查项

### Nuxt 版本和目录约定

检查：

- Nuxt 4 项目是否真正使用默认 `app/` 应用目录，还是长期依赖 `srcDir: '.'` 兼容旧结构。
- `app.vue`、`pages/`、`layouts/`、`plugins/`、`middleware/`、`components/`、`composables/`、`assets/`、`utils/` 的位置是否符合当前 Nuxt 版本约定。
- `~/`、`@/`、`~~/`、`@@/` 的使用是否清楚地区分应用源码和仓库根目录。
- 是否通过 experimental 配置或底层 Vite 配置绕过 Nuxt 应自行处理的问题。
- `ssr: false` 是否是明确产品和部署选择，而不是为绕开问题临时关闭。

Nuxt 4 项目如果仍使用旧式根目录应用结构，应作为迁移不完整或兼容模式风险记录。

### 页面、组件和领域边界

检查：

- 页面是否只负责路由入口、布局组合和少量页面状态。
- 大页面是否同时承担布局、状态、数据模型、表单、样式、快捷键、mock 和 API 映射。
- 业务组件是否进入领域目录，而不是直接散落在 `components/` 根目录。
- 基础组件、领域组件、页面专属组件是否可以区分。
- `composables` 是否只处理一个清晰问题，是否混入页面 UI 细节。
- `stores` 是否只承载业务状态，是否塞入 API 传输细节或 UI 文案。
- `types` 是否承载共享领域类型，是否和后端 payload、view model、表单模型混在一起。
- `utils` 是否纯工具化，是否被业务 mock、临时数据或组件逻辑污染。

### Nuxt UI 和组件库基线

如果项目要求使用 Nuxt UI，必须重点检查：

- 新增页面是否默认使用 `UButton`、`UModal`、`UCard`、`UForm`、`UPage`、`UPageHeader`、`UPageBody`、`UPageGrid` 等 Nuxt UI 组件。
- 是否仍维护自建 Button、Modal、Card、Drawer、Table、Select 等基础控件。
- 是否存在 Nuxt UI、自建基础组件、页面硬编码 Tailwind 三套体系并存。
- 项目 wrapper 是否是 Nuxt UI 的薄封装，还是另起一套设计系统。
- 同类控件的尺寸、颜色、圆角、loading、disabled、error、focus、a11y 是否一致。
- 新页面是否绕过 Nuxt UI theme，直接写大量局部 `ui` 配置或 Tailwind 任意值。

结论要具体描述基线失效、重复建设或组件体系分裂，不评价视觉喜好。

### 主题、Tailwind 和全局样式体系

检查：

- `config/theme.ts`、`app.config.ts`、Nuxt UI theme、Tailwind theme 是否职责清楚。
- 主题 token 是否被业务页面真实使用。
- 页面是否大量出现 `bg-[#...]`、`text-[...]`、`shadow-[...]`、`rounded-[...]`、`rgba(...)`、任意渐变和任意尺寸。
- 全局 CSS 是否只放 reset、基础层和真正跨域 utility。
- 全局 CSS 是否混入具体业务场景样式、第三方组件覆盖或页面专属类。
- 第三方组件样式覆盖是否集中管理，例如 Vue Flow、地图、图表、编辑器。
- 页面级 `<style>` 是否用于局部必要覆盖，还是成为绕过主题体系的主要方式。
- 移动端、桌面端、固定画布、表格、工具栏等布局尺寸是否有系统约束。

前端评审必须检查主题样式是否规范化、系统化、体系化。

### 包管理、仓库治理和依赖治理

检查：

- 包管理器是否单一。在当前用户环境中，Node.js 项目默认必须使用 Bun；不要主动使用 npm。Bun 项目不应出现 `package-lock.json`、`pnpm-lock.yaml`、`yarn.lock`。
- 锁文件是否与 `package.json` 一致。
- Node.js 项目的包安装环境应由个人环境或 CI 环境配置处理。项目级 `.npmrc`、`bunfig.toml` 不应提交包源地址、scope 源、代理、认证、证书路径或其他只属于某一运行环境的配置。
- 是否引入重复 UI 库、重复状态库、重复请求库。
- 新增依赖是否和现有架构匹配。
- `.gitignore` 是否覆盖 Nuxt 和前端真实产物，例如 `.nuxt/`、`.output/`、`dist/`、`node_modules/`、coverage、Playwright report、trace、浏览器 profile、构建日志和本地 `.env`。
- `.gitignore` 是否误忽略应提交内容，例如 `bun.lock`、源码、类型定义、主题配置、测试用例、公共静态资源清单。
- `.gitattributes` 是否处理换行规范、二进制资源和 LFS 规则。
- Git LFS 是否只用于确实需要版本化的大体积前端资源，例如视频、设计导出、三维模型、地图瓦片样例、大型图片或演示数据；不要把普通源码、CSS、JSON 配置、小图标或锁文件放进 LFS。
- 构建产物、缓存、`.nuxt`、`.output`、日志、临时 profile 是否污染仓库。

### 代码格式化和质量配置

检查：

- ESLint、Prettier、`.editorconfig`、TypeScript、Tailwind class 排序规则是否一致。
- 是否使用 `prettier-plugin-tailwindcss` 或等价机制约束 Tailwind class 顺序。
- 是否存在 `format:check` 或 `prettier --check .`，不要用 `format:fix` 冒充格式检查。
- lint 是否覆盖 Vue SFC、TypeScript、Nuxt 自动导入和 Prettier 规则。
- typecheck 是否有独立入口，例如 `vue-tsc --noEmit` 或 Nuxt typecheck。
- 配置文件是否过度分散，是否存在 Nuxt、Vite、Tailwind、PostCSS、ESLint 规则互相覆盖。
- 是否有页面级 `<style>`、任意 Tailwind 值、全局 CSS 和 Nuxt UI theme 多处同时定义同一类样式规则。

格式化和 lint 配置要能支持“只检查、不修改”的评审流程。缺少 check 入口时，记录为质量门禁缺失。

### 命名和业务术语

检查：

- 页面、组件、composable、store、type、utils 命名是否统一。
- 文件命名是否符合项目约定，例如 kebab-case 或 PascalCase 是否混用。
- 组件名是否表达职责，不要用模板名、旧项目名、无关产品名。
- 业务术语是否统一，例如“试验”和“实验”不能混用。
- 路由、菜单、页面标题、类型名、mock 数据、API helper 是否使用同一套业务语言。
- 状态枚举、权限、运行态、节点类型、表单字段命名是否系统化。

术语错误要作为工程问题记录，因为它会污染代码、文档、接口和后续大模型生成结果。

### 静态检查、格式检查、类型检查、构建和测试

优先查 `package.json` scripts，再按项目事实运行或记录缺失：

- 依赖安装：默认使用 Bun，不混用。
- 静态检查：`bun run lint`。
- 格式检查：优先 `format:check`、`prettier --check .`，不要用 `format:fix` 代替检查。
- 类型检查：`vue-tsc --noEmit`、`nuxt typecheck` 或项目脚本。
- 构建：`bun run build`。warning 需要记录。
- 测试：`bun test`、`vitest`、`playwright test` 或项目脚本。

如果项目只有 `format:fix` 没有 format check，记录为质量门禁缺失。  
如果 lint、typecheck、test 脚本缺失，记录为验证入口不完整。  
如果命令无法执行，说明原因，不写成通过。

### 测试和调试产物治理

检查：

- 是否存在根目录日志、大体积调试文件、浏览器 profile、trace、截图、coverage、临时目录。
- dev server、Playwright、浏览器调试、构建日志是否输出到专用目录。
- `.gitignore` 是否覆盖真实产物，且没有掩盖应提交的测试基线、fixture 或配置。
- 是否有清理命令或文档。

根目录长期残留调试日志和临时目录，说明测试与调试流程缺少工程边界。

### Git 历史、文档和提交规范

检查：

- Git 历史中是否有大体积前端资源、构建产物、测试 trace 或本地 profile 直接进入普通 Git 对象。
- Git LFS、`.gitignore`、`.gitattributes` 是否和当前前端资源、测试产物、构建产物匹配。
- README 是否还是模板说明。
- AGENTS 是否与当前代码一致。
- 命令说明是否真实可执行。
- Nuxt 版本、UI 基线、目录规范、包管理器、检查命令是否同步。
- Git 提交信息是否符合正式项目要求，并按 `review-engineering` 与 `/git-commit` 标准检查 subject、body、语言、逻辑单元、历史可追溯性和是否夹带过程噪音。

## 问题分级

- 高：Nuxt 目录迁移不完整、UI 组件库基线失效、主题体系失控、构建或类型检查 warning、lint/typecheck/build/test 不可用、严重仓库污染、错误提交大体积资源或敏感配置、目录边界混乱。
- 中：页面职责过重、业务组件散落、全局 CSS 职责过宽、业务术语混乱、文档漂移、项目级包安装环境配置不当、格式化配置冲突、gitignore 或 LFS 规则不完整、提交规范缺失。
- 低：局部命名不一致、个别文件位置不理想、少量配置说明不清。

只写真实问题。没有证据不要写。

## 报告结构和表达要求

沿用 `review-engineering` 的报告结构、问题定性和表达要求，报告标题用 `# <项目名>前端工程评审报告`。

必须按 `review-engineering` 的报告落地规则，在项目根目录 `docs/reviews/` 下生成或合并 `YYYY-MM-dd-主题描述.md` 评审报告。

评审范围写清楚：本次只评审 Nuxt/Vue 前端工程体系、架构规范和风险，不评价功能需求完成度、UI 喜好或单个交互 bug。检查情况中列出已执行或无法执行的 lint、format check、typecheck、build、test 命令及结果。
