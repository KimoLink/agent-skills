---
name: review-unreal
description: Use when 用户要求对 Unreal Engine、UE、UE5、虚幻引擎、实时渲染、仿真演示、游戏、数字孪生或 Unreal 工具项目做工程级评审、资产治理审查、C++ 模块架构审查或 Unreal 工程质量审查；不要用于普通功能需求验收、演示效果评价、视觉效果评价或只检查某个运行 bug。
---

# Unreal 工程评审

## 定位

这是 Unreal Engine 项目的工程级评审流程。它是 `review-engineering` 的 Unreal 专项版本，重点看 Unreal 工程体系、C++ 模块边界、Blueprint 和资产治理、配置管理、构建发布路径、仓库治理和长期维护风险，不做功能需求验收、演示效果评价或视觉效果评价。

评审对象包括 `.uproject`、`Source/`、`Content/`、`Config/`、`Plugins/`、`*.Build.cs`、`*.Target.cs`、C++ 模块、Blueprint、资产命名、Cook/Automation、Git LFS、DerivedDataCache/Saved/Intermediate/Binaries 治理、文档同步和提交规范。

**REQUIRED SUB-SKILL:** 先阅读并采用 `review-engineering` 的通用工程基线。

## 使用方式

- 先采用 `review-engineering` 的通用基线、执行红线、问题定性和报告落地要求。
- 再使用本 skill 的 Unreal 专项清单补充检查；最终只输出一次评审、一次结论和一份报告。
- 不把项目能在编辑器打开、关卡能运行或打包能启动当成工程合格。
- Unreal 项目常受引擎版本、平台 SDK、许可证、插件和大资源影响；没有可靠命令入口或环境时不要硬上本地构建。
- 能检查的静态结构、模块边界、资产命名、配置、测试入口、构建说明、Git LFS 和产物治理必须检查。
- 有自动化编译、Cook、Automation 或构建入口时，warning 需要作为风险记录。

## 先确认项目事实

读取：

- 存在的 `AGENTS.md`、README、开发文档、构建文档、资产规范、命名规范。
- `.uproject`、`Config/Default*.ini`、`Config/` 关键配置。
- `Source/`、`Plugins/`、`Content/`、`Build/`、`Scripts/`、`Tests/`。
- `*.Build.cs`、`*.Target.cs`、模块头文件和实现文件。
- 关键 Unreal 资产：`.uasset`、`.umap`、Blueprint、材质、纹理、模型、动画、Niagara、DataAsset、DataTable。
- `.gitignore`、`.gitattributes`、Git LFS 规则、`.editorconfig`。

核对：

- Unreal 版本、插件版本、目标平台和文档是否一致。
- 项目类型是游戏、仿真演示、实时渲染、数字孪生、XR、桌面端展示、编辑器工具还是运行时插件。
- 是否使用 C++、Blueprint、Gameplay Ability System、Mass、World Partition、Data Layers、Niagara、Chaos、Pixel Streaming 等关键能力。
- 是否有自动化测试、BuildGraph、RunUAT、Cook、Pak、平台打包或团队构建说明。
- Git LFS 和 `.gitignore` 是否匹配 Unreal 资产形态和生成目录。

## 核心检查项

### 工程结构和目录边界

检查：

- `.uproject` 中模块、插件、目标平台、引擎插件启用状态是否和实际代码一致。
- `Source/` 是否按 Runtime、Editor、Developer、ThirdParty、Tests 等边界组织。
- `Content/` 是否按项目资产规范组织，避免临时导入、样例包、供应商默认目录、个人试验目录进入正式路径。
- `Config/` 是否只保留项目需要的默认配置，避免个人编辑器偏好、本机路径和临时平台配置污染。
- `Plugins/` 是否区分自研插件、第三方插件和引擎插件依赖，插件内是否有独立 `Source/`、`Content/`、`Config/` 边界。
- `DerivedDataCache/`、`Saved/`、`Intermediate/`、`Binaries/`、`Build/` 输出、Cook/Pak 产物、日志和崩溃 dump 是否被正确忽略。
- Demo、Sample、Prototype、Backup、Old、Temp 等目录是否进入正式工程主路径。

### C++ 模块、Build.cs 和 Target.cs

检查：

- `*.Build.cs` 中 Public/Private 依赖是否清楚，避免把内部依赖暴露到 PublicDependencyModuleNames。
- 模块是否按运行时、编辑器、平台适配、第三方 SDK、测试或工具拆分。
- Public/Private 头文件边界是否明确，避免私有实现从 Public 头文件泄漏。
- `*.Target.cs` 是否明确目标类型、平台、构建配置、模块入口和编辑器目标。
- Actor、Component、Subsystem、GameInstance、GameMode、Controller 等入口是否只负责组合和调度，不承载大量领域逻辑。
- 平台宏、引擎版本宏、路径拼接和第三方 SDK 调用是否集中在适配层。
- 编译警告、Unreal Header Tool warning、Include 顺序、循环依赖和大范围全局头文件污染是否被记录。

### Blueprint 和资产治理

检查：

- Blueprint 是否有稳定命名、目录归属和职责边界，避免大型 Blueprint 承担系统级业务流程。
- Blueprint 与 C++ 的边界是否清楚：C++ 承担核心能力和可测试逻辑，Blueprint 承担组合、配置和表现层逻辑。
- 关卡、子关卡、World Partition、Data Layers、Prefab 等资产组织是否有规则。
- 材质、纹理、模型、动画、Niagara、DataAsset、DataTable、Widget Blueprint 是否按类型和业务域归档。
- 是否存在 Missing Reference、Redirector 长期未清理、重复资产、未使用大资源、供应商默认命名或 `NewBlueprint`、`TestMap`、`Final2` 等临时命名。
- 大型二进制资产是否通过 LFS 管理，文本配置和源码是否仍可正常 diff。

### 插件、第三方依赖和平台适配

检查：

- 自研插件是否有清楚边界，不把项目业务代码散落到第三方插件目录。
- 第三方插件是否有版本、来源、许可证、启用范围和升级说明。
- 平台 SDK、Android/iOS/Windows/Linux/Console 配置是否集中管理，避免个人绝对路径和本机环境写入仓库。
- Runtime 插件和 Editor 插件是否分离，编辑器工具不应进入运行时构建。
- 插件 Content 是否经过筛选，避免完整样例、文档、预览图和未使用资源全量提交。

### Git LFS、gitignore 和仓库治理

检查：

- `.gitignore` 是否覆盖 `.vs/`、`.idea/`、`DerivedDataCache/`、`Intermediate/`、`Saved/`、`Binaries/`、构建输出、Cook/Pak 产物、日志、crash dump 和本地配置。
- `.gitignore` 是否误忽略 `.uproject`、`Config/Default*.ini`、`Source/`、`Plugins/*/Source/`、必要的 `Content/` 资产或构建脚本。
- `.gitattributes` 是否配置 Unreal 资产、换行规则、merge/diff 策略和 LFS。
- Git LFS 是否覆盖应版本化的大体积二进制资源，例如 `.uasset`、`.umap`、`.fbx`、`.psd`、`.png`、`.wav`、`.mp4`、`.exr`、`.tif`、大型样本数据和第三方二进制。
- Git LFS 是否过宽，避免把 `.cpp`、`.h`、`.cs`、`.ini`、`.uproject`、`.json`、`.md` 等文本文件放进 LFS。
- Git 历史中是否已经混入 DDC、Saved、Intermediate、Binaries、打包产物、日志、完整未清理插件包或个人工程文件。

### 静态检查、自动化测试、Cook 和构建

先判断是否具备可靠自动化入口。Unreal 项目没有引擎安装、平台 SDK、许可证、插件资源或明确命令时，不要硬上构建。

可检查项：

- 是否存在 BuildGraph、RunUAT、AutomationTool、Editor commandlet、Cook、Pak、平台打包脚本或团队构建说明。
- 是否有 Automation Spec、Functional Test、Gauntlet、单元测试或编辑器测试入口。
- 是否有 C++ 格式化、clang-format、clang-tidy、静态分析或团队 IDE 规则。
- 如有命令入口，再检查编译、UHT、Cook、Automation 和打包日志；warning 需要记录。
- 没有自动化入口时，重点检查目录、模块、资产、配置、构建文档、测试入口和产物治理。

不能把未运行的 Unreal 构建写成通过。只能写“未执行”，并说明原因。

### 命名、文档和提交规范

检查：

- C++ 类、模块、插件、Blueprint、Map、材质、纹理、动画、DataAsset、DataTable、Widget 和配置键命名是否统一。
- 业务术语是否统一，避免旧项目名、模板名、错误业务词残留。
- README、已存在的 AGENTS、构建文档、资产规范、命名规范是否与当前工程一致。
- Unreal 版本、插件版本、目标平台、构建命令、Cook 命令、测试命令是否同步。
- Git 提交信息是否符合正式项目要求，并按 `review-engineering` 与 `/git-commit` 标准检查 subject、body、语言、逻辑单元、历史可追溯性和是否夹带过程噪音。

## 专项分级

- 高：`.uproject` 和模块事实不一致、C++ 模块边界失控、Runtime/Editor 混放、Git LFS 规则错误、DDC/Saved/Intermediate/Binaries 或打包产物污染 Git、完整未清理第三方插件包进入正式仓库、编译/Cook/Automation 存在 warning、测试和构建入口缺失且无说明。
- 中：Blueprint 职责过重、Content 目录组织混乱、资产命名不统一、Redirector 或重复资产长期堆积、配置漂移、平台适配散落、格式化配置缺失、gitignore 不完整、文档漂移、提交规范缺失。
- 低：局部命名不一致、个别资产位置不理想、少量配置说明不清。

## 报告补充

沿用 `review-engineering` 的报告结构、问题定性和表达要求，报告标题用 `# <项目名>Unreal 工程评审报告`。

评审范围写清楚：本次只评审 Unreal 工程体系、C++ 模块边界、资产治理、构建发布路径和风险，不评价功能需求完成度、演示效果或视觉效果。检查情况中列出已执行或无法执行的静态检查、编译、Automation、Cook、打包命令及结果。
