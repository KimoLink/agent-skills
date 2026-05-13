---
name: review-engineering
description: Use when 用户要求做工程评审、体系评审、架构规范审查、项目工程质量审查或非功能需求层面的代码仓库审查，适用于前端、后端、Rust、Python、.NET、C++、Qt、Unity、Unreal、桌面端、SDK、数据工程和混合仓库；不要用于普通功能 bug review、需求验收或只看业务交互是否正确的评审。
---

# 工程评审

## 定位

从技术部门对项目执行质量进行工程评审。评审对象是代码仓库的工程体系，不是功能需求验收。

评审目标是判断项目是否具备可维护、可协作、可演进、可验证的工程基础。不同技术栈检查命令不同，可自动化程度也不同，但评审标准一致：目录清晰、边界明确、命名统一、规范可执行、验证路径可信、产物不污染、仓库治理清楚、文档与代码一致、提交日志可追溯。

## 基本原则

- 先识别项目类型和技术栈，不要把某次前端评审经验硬套到所有项目。
- 以项目事实和项目规范为依据，不用个人偏好凑问题。
- 先确认评审依据层级：本 skill 的硬性工程基线、用户或部门通用要求、项目已有规范、仓库事实、工具配置或团队约定。报告里要写清楚依据来自哪里。
- 本 skill 包含硬性工程基线和建议性检查项。项目 `AGENTS.md`、README 或现场文档不能降低硬性工程基线；如果项目规范和硬性基线冲突，应记录为“项目规范与通用工程基线冲突”，而不是按项目规范放行。
- 项目规范可以补充、细化或提高要求；只有本 skill 未写成硬性要求的部分，才按项目规范和现场事实判断。
- 若项目缺少规范，只能定性为“规范缺失带来的工程风险”或“建议补充规范”，不要写成违反既定规范。
- 若项目因技术栈、设备、授权、历史包袱等原因无法满足硬性基线，只能记录为带证据的例外风险或待确认例外，不能默认豁免。
- 问题定性要区分五类：违反硬性工程基线、项目规范与工程基线冲突、违反项目已确认规范、规范缺失导致风险、可选优化建议。
- 评审结论必须能落到文件、目录、配置、命令输出或仓库状态。
- 功能是否满足需求不是主要评价对象；只有当功能实现方式暴露工程体系问题时才写入。
- 不能把“能跑起来”当成工程合格。静态检查、格式检查、编译或构建、测试和产物治理都要按项目类型评估。
- 有明确自动化编译或构建入口时，原则上不能有警告。若项目类型或环境不适合自动构建，不要硬上，记录原因并加强其他工程维度检查。
- 不使用模板腔、口号式判断或对立转折式套话。直接说明问题、证据、风险和建议。

## 与专项评审的关系

本 skill 是所有工程级评审的通用基线。Nuxt/Vue、Nest/Node、Unity、Unreal、Qt、.NET、Rust 等项目使用专项 skill 时，必须先阅读并吸收本 skill 的硬性工程基线，再把通用基线和专项清单合并成一次评审、一次结论和一份报告。

专项 skill 可以补充更细的技术栈检查项，不能跳过本 skill 的通用要求，不能把专项偏好写成抵消通用硬性基线的理由。

选择规则：

- Nuxt/Vue/Web 前端项目：结合本 skill 的通用工程基线和 `review-nuxt` 的前端专项清单做一次评审。
- NestJS/Node.js 后端项目：结合本 skill 的通用工程基线和 `review-nest` 的后端专项清单做一次评审。
- Unity 项目：结合本 skill 的通用工程基线和 `review-unity` 的 Unity 专项清单做一次评审。
- Unreal Engine/UE/UE5 项目：结合本 skill 的通用工程基线和 `review-unreal` 的 Unreal 专项清单做一次评审。
- Qt Widgets/QML/C++ 桌面端项目：结合本 skill 的通用工程基线和 `review-qt` 的 Qt 专项清单做一次评审。
- C#/.NET/ASP.NET Core/WPF/WinUI/Avalonia/MAUI 项目：结合本 skill 的通用工程基线和 `review-dotnet` 的 .NET 专项清单做一次评审。
- Rust 后端/CLI/库/workspace 项目：结合本 skill 的通用工程基线和 `review-rust` 的 Rust 专项清单做一次评审。
- 混合仓库：先分出子系统和通用仓库风险，再把本 skill 的通用工程基线与各子系统对应专项清单合并使用，形成一次整体评审。

## 常见误用红线

出现以下情况时必须停止并修正评审过程：

- 只执行专项评审，跳过本 skill 的通用工程基线。
- 用项目 `AGENTS.md`、README 或现场文档降低硬性工程基线。
- 没有命令输出、文件证据或仓库状态，却写成“通过”“符合”或“已验证”。
- 把普通功能验收、视觉喜好或业务需求争议写成工程体系问题。
- 为了凑问题写无证据结论，或用个人偏好替代已确认基线。
- 命令无法执行时不说明阻断原因，或把未执行检查写成已通过。
- 只在对话里输出评审结论，没有在项目根目录的 `docs/reviews/` 下生成评审报告文档。

## 项目类型识别

先根据仓库文件判断项目类型：

- Vue/Nuxt/Web 前端：`package.json`、`nuxt.config.*`、`vite.config.*`、`src/`、`app/`、`pages/`、`components/`。
- Node.js 后端：`package.json`、`src/`、`server/`、`routes/`、`controllers/`、`services/`、ORM 配置。
- Rust 后端或 CLI：`Cargo.toml`、`crates/`、`src/main.rs`、`src/lib.rs`、workspace 配置。
- Python：`pyproject.toml`、`requirements*.txt`、`src/`、`tests/`、`ruff`、`pytest`、`mypy` 配置。
- C#/.NET：`.sln`、`.csproj`、`Directory.Build.props`、`Program.cs`、`Tests` 项目。
- C++：`CMakeLists.txt`、`src/`、`include/`、`tests/`、`conanfile.*`、`vcpkg.json`、`.clang-format`、`.clang-tidy`。
- Qt：`.pro`、`.pri`、`CMakeLists.txt`、`.ui`、`.qrc`、Widgets/QML 目录、moc/uic/rcc 生成链。
- Unity：`Assets/`、`Packages/manifest.json`、`ProjectSettings/`、`.unity`、`.asmdef`。
- Unreal：`.uproject`、`Source/`、`Content/`、`Config/`、`.Build.cs`。
- 桌面端：Tauri、Electron、WPF、WinUI、Avalonia、Qt 等壳层、平台能力和打包配置。
- 混合仓库：先分出子系统，再分别评审，最后检查跨系统契约。

无法判断时，先列出候选类型和证据，再继续检查，不要臆测。

## 必做检查

### 项目规范和事实对照

读取并对照：

- 项目规则：`AGENTS.md`、README、开发文档、架构文档。
- 构建入口：`package.json`、`Cargo.toml`、`pyproject.toml`、`.sln`、`CMakeLists.txt`、Unity/Unreal 配置等。
- 锁文件和包管理器：`bun.lock`、`package-lock.json`、`pnpm-lock.yaml`、`Cargo.lock`、`poetry.lock`、`packages.lock.json` 等。
- 工具配置：ESLint、Prettier、Ruff、mypy、clippy、rustfmt、EditorConfig、dotnet format、clang-format、clang-tidy、Unity asmdef、Unreal Build.cs。
- 仓库配置：`.gitignore`、`.gitattributes`、Git LFS 规则、`.editorconfig`、提交规范文档。

检查文档和代码是否漂移：框架版本、包管理器、命令、目录约定、业务术语、格式化规则、提交规范是否一致。

### 仓库治理、忽略规则和产物治理

检查：

- 根目录是否残留临时日志、调试输出、浏览器 profile、trace、截图、构建缓存、生成目录。
- `.gitignore` 是否覆盖本项目实际工具产物。
- `.gitignore` 是否过宽，避免把应提交的源码、配置、资源清单或锁文件误忽略。
- `.gitignore` 是否过窄，避免把本地环境、密钥、缓存、构建产物、IDE 临时文件、测试输出和大体积生成文件纳入版本库。
- `.gitattributes` 是否定义文本换行、二进制文件、导出规则和 LFS 规则。
- Git LFS 是否只用于确实需要版本化的大体积二进制资源，例如美术资源、模型、样本数据、视频、安装包或引擎资产；不要把普通源码、配置、小图标、锁文件或文本数据放进 LFS。
- 已进入 Git 的大文件是否符合项目类型和 LFS 规则；历史中是否存在明显误提交的大体积产物。
- 测试、调试、浏览器自动化和构建日志是否进入专用目录。
- 是否有不该出现的锁文件或包管理器混用。
- 是否把本地环境配置写死到项目级文件，例如包源地址、代理、认证信息、绝对路径、本地证书路径、个人 token。

包源选择本身不是问题。外网、内网、团队环境可以使用不同包源；问题是仓库不应把某个环境的包源、认证、代理或本机路径强加给所有人。
按工具机制允许写入项目配置的包源信息不按普通本地环境配置处理，例如 Unity 的 scoped registry 可以写在 `Packages/manifest.json`。此类配置的评审重点是是否项目依赖需要、团队是否可访问、scope 是否准确、是否夹带个人 token、临时账号或本机路径。

### 代码风格和格式化配置

检查：

- 是否存在统一格式化配置，例如 `.editorconfig`、Prettier、rustfmt、Ruff format、dotnet format、clang-format、Unreal/Unity 团队规则。
- 格式化配置是否和项目文档、开发命令一致。
- 是否有只修复不检查的脚本，例如只有 `format:fix` 没有 `format:check`。
- 是否存在多套互相冲突的格式化规则，例如 EditorConfig、Prettier、IDE 配置和语言工具规则不一致。
- 是否把格式化和 lint 混成一个不可审计的自动修复命令，导致评审时无法判断代码是否原本合规。
- 是否存在大量未格式化文件、局部文件绕过格式规则或生成代码未明确排除。

格式化配置属于工程质量门禁。评审时优先执行 check 类命令；不要为了评审擅自格式化全仓。

### 架构边界和目录结构

检查：

- 入口层是否轻量：页面、controller、command handler、main、bin、MonoBehaviour、Actor、Subsystem 是否只负责组合和调度。
- 业务域是否有稳定目录或模块，而不是散落在根目录、工具目录或页面中。
- 基础设施、领域逻辑、接口适配、配置、类型/模型、测试 fixture 是否可区分。
- API、数据库访问、外部服务、状态管理、校验、mock、序列化是否集中在合理边界。
- 大文件是否承担过多职责。
- 框架升级是否只升依赖、不迁移目录和约定。

### 命名和代码规范

需要检查命名是否规范化、体系化、系统化：

- 目录命名是否统一，例如 kebab-case、snake_case、PascalCase 是否混用。
- 文件命名是否符合技术栈和项目约定。
- 类型、变量、函数、组件、模块、路由、命令、接口字段是否使用同一套业务语言。
- 是否存在模板项目名、旧项目名、错误业务术语、无关产品名残留。
- 缩写、前缀、后缀、状态枚举、错误码、DTO、ViewModel、Store、Service、Repository 等命名是否有一致规则。

术语混用属于工程问题。比如业务域是“试验调度”，就不能在业务语境中混用“实验调度”。

### 静态检查、格式检查、编译和测试

根据项目类型选择实际命令。原则是检查而不是擅自大范围修复。不是所有项目都适合在评审环境里自动构建，例如 Unity、Unreal、部分桌面端、嵌入式或依赖专用设备/授权/大资源的项目。遇到这种情况，不要强行构建；应说明阻断原因，并重点检查目录、资源、配置、命名、测试入口、日志产物或团队既有构建说明。

前端 / Node.js：

- 在当前用户环境中，Node.js 项目默认必须使用 Bun；不要主动使用 npm。项目若存在 `package-lock.json`、`pnpm-lock.yaml`、`yarn.lock` 或 npm/pnpm/yarn 命令，应作为包管理器混用或项目规范冲突风险核对。
- Node.js 项目的包安装环境应由个人环境或团队约定环境配置处理。项目级 `.npmrc`、`bunfig.toml` 不应提交包源地址、scope 源、代理、认证、证书路径或其他只属于某一运行环境的配置。
- 常见检查：`bun run lint`、`bun run format:check`、`bun run typecheck`、`bun run build`、`bun test`。
- 如果只有 `format:fix` 没有 check 命令，记录为质量门禁缺失，不要为了检查擅自格式化全仓。

CI 不作为默认检查项；只有用户、项目文档或团队规范明确要求 CI 时，才检查 CI 配置并记录相关问题。

Rust：

- 常见检查：`cargo fmt --all -- --check`、`cargo clippy --all-targets --all-features -- -D warnings`、`cargo test --all-targets --all-features`、`cargo build --all-targets --all-features`。
- 只读评审优先使用 `cargo fmt --all -- --check`。如果从评审转入代码修复，修改完成后必须执行 `cargo fmt --all` 和 `cargo clippy --all-targets --all-features -- -D warnings`。
- 除 `cargo fmt --all` 外，`cargo check`、`cargo clippy`、`cargo test`、`cargo build`、`cargo run`、`cargo doc` 等会写入 `target` 或运行 build script 的命令，必须按用户环境要求直接申请非沙箱执行；原因写明：沙箱可能导致构建产物写入失败，例如 `拒绝访问 (os error 5)`。
- 禁止使用 `CARGO_TARGET_DIR` 绕开 Cargo 构建产物写入问题。
- clippy 警告必须视为问题，不建议用 `#[allow]` 掩盖。

Python：

- 常见检查：`ruff check`、`ruff format --check`、`mypy` 或 `pyright`、`pytest`。
- 如果项目没有类型检查或测试入口，记录为风险。

C#/.NET：

- 常见检查：`dotnet format --verify-no-changes`、`dotnet build -warnaserror`、`dotnet test`。
- 编译 warning 应视为工程质量问题。

C++：

- 常见检查：CMake configure、build with warnings as errors、CTest、clang-tidy、clang-format check。
- 检查 `src/`、`include/`、`tests/`、`cmake/`、`third_party/` 边界，避免头文件、实现文件、平台适配和第三方代码混放。
- 编译 warning、未声明依赖、平台宏散落、全局 include 污染都应作为工程风险。

Qt：

- 检查 Widgets/QML、资源 `.qrc`、`.ui`、翻译文件、平台插件、打包配置是否有清晰边界。
- CMake Qt 项目检查 `AUTOMOC`、`AUTOUIC`、`AUTORCC`、模块依赖和资源路径；qmake 项目检查 `.pro/.pri` 拆分是否清晰。
- 重点看 UI 层、业务逻辑、设备/系统适配、线程和信号槽边界是否混在一起。

Unity：

- 检查 `Packages/manifest.json`、`ProjectSettings/`、asmdef、Editor 脚本、资源目录和场景命名。
- 如有 batchmode 命令，再检查 EditMode/PlayMode tests、编译日志和资源导入警告；没有自动化入口时不要硬上本地构建。
- 重点按已确认的 Unity 目录评审基线检查 `Assets/` 一级目录，例如 `Arts/`、`Plugins/`、`Resources/`、`Scenes/`、`Scripts/`、`Tests/`；`Arts/` 下是否按资源类型复数目录组织；第三方资产、样例资源、临时导出和大体积插件包是否经过筛选和清理。

Unreal：

- 检查 `.uproject`、`Source/` 模块、`Content/`、`Config/`、插件、Build.cs、Target.cs。
- 如有命令入口，再检查 build、cook、automation tests、蓝图编译警告；没有自动化入口时不要硬上本地构建。
- 重点看 C++ 模块边界、Blueprint 资产命名、Content 目录组织和配置漂移。

如果命令无法运行，要写清楚阻断原因。不要把未验证状态写成通过。

### 前端专项：主题和样式体系

只有在前端、桌面前端壳层或 UI 项目中使用本节。

检查：

- 项目要求的标准组件库是否被执行，例如 Nuxt UI、Element Plus、Ant Design、MUI、WinUI、Unity UI Toolkit 等。
- 是否同时存在标准组件库、自建基础组件、页面硬编码样式多套体系。
- 主题 token 是否真正约束业务页面。
- 是否大量直接写任意颜色、任意阴影、任意尺寸、局部渐变。
- 全局 CSS、全局样式表、主题资源是否混入业务场景样式。
- 第三方组件覆盖是否集中管理。

结论要具体，例如“Nuxt UI 标准组件库基线失效”“主题 token 未形成约束”“全局样式承担业务场景职责”。

### Git 仓库历史和提交规范

检查仓库历史和项目规范：

- Git LFS 使用历史是否合理，是否存在二进制大文件直接进入普通 Git 对象的问题。
- `.gitignore`、`.gitattributes` 和 LFS 规则是否与项目类型、资源形态、构建产物和测试产物匹配。
- 是否提交了 IDE 缓存、本地配置、临时日志、浏览器 profile、构建输出、测试 trace、coverage、崩溃 dump、私有证书或密钥样例。
- 是否要求中文提交日志。
- subject 是否有语言和风格约束。
- 是否必须包含 body。
- body 是否说明具体变更、边界、影响和验证。
- 是否存在大量英文模板、泛化 subject、无 body 提交。
- 提交日志是否面向后续维护者阅读，而不是记录开发过程或内部协作暗号。内部阶段号、临时任务代号、个人执行过程、环境限制等内容，只有在项目公开规范中有明确含义时才适合进入日志。
- subject 是否准确描述工程变更本身。评审时留意过于含糊或口语化的动词，例如只写“完善”“补充”“处理”“承接”但看不出具体对象和变化；如果对象、动作和影响清楚，则不需要机械扣字眼。
- body 是否补足“改了什么、边界在哪里、对后续维护有什么影响”。验证命令、未执行原因、环境缺口等过程信息通常更适合放在交付说明、PR 描述或评审报告中；只有项目约定要求记录验证结果时，才作为提交日志检查项。
- 历史重写是否处于可控范围。活跃开发期、本地未发布分支可以建议整理提交信息；已共享或发布的历史应先评估协作影响，不要为了日志洁癖破坏团队基线。

若项目要求参考 `/git-commit`，按该标准检查：提交前看 status、history、diff；一个逻辑单元一个提交；提交信息基于 staged diff；提交后检查最新日志。

## 问题分级

- 高：架构基线失效、可自动化构建或编译存在警告、静态检查不可用、测试体系不可用、目录边界混乱、公共契约不稳定、严重仓库污染、错误提交大体积产物或敏感配置、框架迁移不完整。
- 中：命名体系不统一、业务术语混乱、文档漂移、入口层职责过重、全局配置或全局样式职责过宽、领域模块散落、格式化配置冲突、gitignore 或 LFS 规则不完整、提交规范缺失。
- 低：局部命名不一致、少量配置说明不清、个别文件位置不理想但尚未形成扩散。

只列真实问题。没有证据的问题不要写。

## 报告结构

评审完成后必须生成 Markdown 评审报告文档，不能只在对话中输出结论。

报告落地规则：

- 报告目录固定为项目根目录下的 `docs/reviews/`。目录不存在时创建。
- 报告文件名使用 `YYYY-MM-dd-主题描述.md`，例如 `2026-05-12-工程体系评审.md`。
- 日期使用评审当天日期；主题描述用简短中文短语，表达评审对象或主题，不使用空格和特殊符号，必要时用连字符连接。
- 生成前先检查 `docs/reviews/` 是否已有同日期报告。
- 如果同日期已有报告，优先合并到当天已有报告中，避免同一天多个零散报告。合并时保留原报告内容，在合适位置追加本次评审范围、检查情况和新增问题；不要覆盖或删除原有结论。
- 只有当同一天确实是不同评审主题且合并会造成混乱时，才新建同日期不同主题文件，并在报告中说明与已有报告的关系。
- 最终回复必须给出报告文件路径，并说明是新建报告还是合并到已有报告。

推荐 Markdown：

```markdown
# <项目名>工程评审报告

## 评审范围

说明本次只评审工程体系、架构规范和风险，不评价功能需求完成度。

## 评审依据

列出本次审查依据，包括本 skill 的硬性工程基线、用户或部门通用要求、项目规范、仓库配置、工具配置或团队约定。没有明确依据的判断，不写成违反规范；项目规范与硬性工程基线冲突时，应作为冲突风险记录。

## 总体结论

概括工程状态、主要风险和优先整改方向。

## 检查情况

列出已执行或无法执行的静态检查、格式检查、编译、测试命令及结果。无法执行时说明原因，不要把未执行写成通过。

## 主要问题

### <问题标题>

说明问题定性、依据、现象、证据、风险和建议。问题定性使用“违反硬性工程基线”“项目规范与工程基线冲突”“违反项目已确认规范”“规范缺失导致风险”“建议优化”之一。

## 整改优先级建议

### 第一阶段：<目标>

- 具体整改项
```

已有总体结论时，末尾不要再写重复总结。

## 表达要求

- 使用中文。
- 直接、专业，不写模板腔、口号和情绪化形容。
- 不使用对立转折式套话。
- 每个重要结论给出证据。
- 风险和建议要具体，能指导整改。
- 用户已确认的事实要接受，不要反复挑战。
- 不确定的因果要写成“需要结合日志确认”“当前证据不足以断定”。
