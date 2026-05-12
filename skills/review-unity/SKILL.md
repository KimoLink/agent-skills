---
name: review-unity
description: Use when 用户要求对 Unity、Unity3D、仿真演示、三维可视化、数字孪生、XR、桌面端展示或 Unity 工具项目做工程级评审、资源治理审查、脚本架构审查或 Unity 工程质量审查；不要用于普通功能需求验收、演示效果评价、视觉效果评价或只检查某个运行 bug。
---

# Unity 工程评审

## 定位

这是 Unity 项目的工程级评审流程。它是 `review-engineering` 的 Unity 专项版本，重点看 Unity 工程体系、资源治理、脚本架构、模块边界、规范执行和长期维护风险，不做功能需求验收、演示效果评价或视觉效果评价。

评审对象包括 `Assets/` 目录组织、asmdef 模块边界、场景和 Prefab 治理、Runtime/Editor 分离、资源导入和清理规则、第三方资产落位、包管理、质量门禁、Git LFS、仓库治理、测试体系、构建入口、文档同步和提交规范。

**REQUIRED SUB-SKILL:** Use `review-engineering` before this skill.

使用本 skill 时，必须先按 `review-engineering` 完成通用工程评审，再进入本 skill 的 Unity 专项检查。本 skill 只补充 Unity 专项要求，不能跳过或降低通用工程基线。

## 评审原则

- 使用中文输出。
- 不写模板腔、口号和对立转折式套话。
- 先确认评审依据层级：`review-engineering` 的通用硬性工程基线、本 skill 的 Unity 专项基线、用户或部门通用要求、项目已有规范、仓库事实、工具配置、CI 或团队约定。报告里要写清楚依据来自哪里。
- 项目 `AGENTS.md`、README 或现场文档不能降低通用硬性工程基线和本 skill 的专项硬性要求；如果项目规范与基线冲突，应记录为“项目规范与工程基线冲突”，而不是按项目规范放行。
- 项目规范可以补充、细化或提高要求；若项目缺少规范，只能定性为“规范缺失带来的工程风险”或“建议补充规范”，不要写成违反既定规范。
- 问题定性要区分五类：违反硬性工程基线、项目规范与工程基线冲突、违反项目已确认规范、规范缺失导致风险、可选优化建议。
- 结论必须有文件、目录、配置、命令输出或仓库状态支撑。
- 不把项目能在编辑器打开当成工程合格。
- Unity 项目不一定适合在评审环境自动构建；没有可靠 batchmode、CI 或许可证环境时不要硬上构建。
- 能检查的静态结构、资源规则、包配置、测试入口、日志产物和 Git 治理必须检查。
- 有自动化编译、测试或构建入口时，warning 需要作为风险记录。

## 先确认项目事实

读取：

- `AGENTS.md`、README、开发文档、构建文档、资源规范、命名规范。
- `ProjectSettings/ProjectVersion.txt`、`ProjectSettings/` 关键配置。
- `Packages/manifest.json`、`Packages/packages-lock.json`。
- `Assets/` 一级目录，重点核对 `Arts/`、`Plugins/`、`Resources/`、`Scenes/`、`Scripts/`、`Tests/`。
- 关键 Unity 资源和工程文件：`*.asmdef`、`*.unity`、`*.prefab`、`*.asset`、`*.meta`。
- `.gitignore`、`.gitattributes`、Git LFS 规则、`.editorconfig`、CI 配置。

核对：

- Unity 版本和文档是否一致。
- 项目类型是仿真演示、三维可视化、数字孪生、XR、桌面端展示、移动端展示还是 Unity 工具。
- 是否使用 URP、HDRP、Built-in、Entities、Input System、Addressables、Netcode 等关键包。
- 是否有自动化测试、batchmode 构建、CI 或团队构建说明。
- Git LFS 和 `.gitignore` 是否匹配 Unity 资源形态。

## 核心检查项

### 目录结构和资源边界

检查：

- `Assets/` 一级目录按已确认的目录评审基线检查：`Arts/`、`Plugins/`、`Resources/`、`Scenes/`、`Scripts/`、`Tests/`。新增一级目录需要有明确理由和项目规范记录；临时导入、样例资源、个人试验目录、插件原始包和导出目录不能直接散落在一级目录。
- 上述 Unity 目录基线是本 skill 的硬性工程基线。项目规范可以在其上补充更细目录，但不能用临时导入习惯、供应商默认目录或个人实验目录替代资源治理基线；确有相反组织方式时，应记录为“项目规范与 Unity 目录基线冲突”并说明风险或例外理由。
- 一级目录命名使用复数形式。既然目录体系采用 `Arts/Plugins/Resources/Scenes/Scripts/Tests`，同一层级出现 `Art/Plugin/Scene/Script/Test` 这类单数目录，应作为命名体系不一致记录。
- 同一层级的目录命名要保持数形、大小写和语言一致。不要在复数英文目录体系里混入单数、中文、供应商默认名或无意义缩写。
- `Arts/` 根目录也按已确认的资源类型复数目录基线检查，例如 `Models/`、`Materials/`、`Textures/`、`Shaders/`、`Animations/`、`Timelines/`、`Sprites/`、`Fonts/`、`Tables/`、`Profiles/`、`Audios/`。同一层级出现 `Model/`、`Material/`、`Texture/`、`Shader/`、`Animation/`、`Timeline/`、`Sprite/`、`Font/` 等单数目录，应作为命名体系不一致记录。
- `Arts/` 下如果需要按业务域继续分区，应放在资源类型目录内部，或在项目规范中明确相反组织方式；不能一部分按资源类型、一部分按业务域、一部分按供应商默认目录混放。
- 不要同时使用多套互相竞争的资源轴线，例如 `Arts/Models/Ships`、`Arts/Materials/UI` 之外，又在 `Arts/ShipAssets`、`Arts/UI_Final`、`Arts/VendorPack` 中继续堆放同类模型、材质、贴图和 Prefab。
- `Scripts/` 下可以按领域或系统继续拆分，并在需要时用 `Runtime/`、`Editor/`、`Tests/` 子目录或 asmdef 表达编译边界；不要为了追求一级目录纯粹性把 Editor 脚本散落到业务代码旁边。
- `Resources/` 是 Unity 特殊目录，应只放确实需要通过 Resources API 动态加载的资源；普通美术资源仍应归入 `Arts/`。
- 是否把临时资源、导入缓存、测试输出、构建产物或个人实验目录放在根目录或 `Assets/` 一级。
- 第三方插件和原生库是否进入 `Plugins/` 或插件治理目录，避免和自研代码、美术资源混放。
- Demo、Sample、Prototype、Backup、Old、Temp 等目录是否进入正式工程主路径。
- 场景、Prefab、ScriptableObject、材质、贴图、动画、Timeline、控制器是否有稳定命名和目录归属。

### 美术资源导入和第三方资产清理

检查：

- 是否存在美术或开发人员直接把 Asset Store 包、DCC 导出目录、插件目录、样例工程拖进 `Assets/` 一级目录的情况；一级目录只允许进入标准目录或经过项目规范批准的目录。
- 是否为了使用一个材质、模型、Shader 或贴图，把几个 G 的完整插件、Demo、Documentation、Example、Source、Sample、Preview、Backup 全量提交。
- 第三方资源是否先进入隔离目录，经过筛选后只把实际使用的资源落位到项目规范目录。
- 未使用资源、样例场景、演示 Prefab、导入说明、预览图、源工程文件是否有清理记录或保留理由。
- 资源命名是否能说明用途、阵营、系统、场景、规格或版本，避免 `mat1`、`new texture`、`demo final 2`、`未命名`、供应商默认名直接进入正式资源。
- 模型、材质、贴图、动画、Timeline、Audio、VFX、Shader Graph 是否有命名前缀、后缀或目录规则；同一目录内不要混用单复数、大小写风格和供应商默认命名。
- 导入设置是否规范，例如贴图压缩、Max Size、sRGB、法线贴图类型、模型缩放、Rig、动画裁剪、音频压缩、平台 override。
- 大体积原始源文件是否确有版本化必要；可再生成、可从供应商包恢复或只作导入中间态的文件不要进入正式仓库。
- `.meta` 是否和资源一起提交，删除资源时是否同步删除无用 `.meta`。

评审时不要只看目录名字是否“好看”。重点判断资源从导入、筛选、命名、落位、引用到清理是否形成流程；没有流程时，后续资源会持续污染仓库、构建体积和场景引用。

### asmdef、脚本架构和 Runtime/Editor 分离

检查：

- 是否使用 asmdef 管理编译边界；大型项目没有 asmdef 应作为工程风险。
- Runtime、Editor、Tests、第三方适配、平台适配是否拆分 assembly。
- Editor 脚本是否只在 Editor assembly 中，避免进入运行时构建。
- MonoBehaviour 是否只负责 Unity 生命周期和对象桥接，不承担大量领域逻辑。
- 领域逻辑、数据模型、系统服务是否能脱离场景对象测试。
- 事件、状态机、输入、相机、UI、资源加载、网络、存档、配置是否有清晰模块边界。
- 静态单例、DontDestroyOnLoad、全局事件和 Service Locator 是否被滥用。

### 场景、Prefab 和资源引用治理

检查：

- 场景是否按用途分层，例如启动场景、主场景、测试场景、演示场景。
- Prefab 是否作为可复用资产管理，避免场景内大量手工对象无法复用。
- Prefab Variant 使用是否有规则，避免层级过深和覆盖混乱。
- 资源引用是否稳定，避免大量 Missing Script、Missing Reference、断链材质和丢失贴图。
- `.meta` 文件是否完整提交，GUID 是否稳定。
- 大型二进制资源是否走 LFS，文本资源是否按 Unity 推荐序列化配置可 diff。
- Tag、Layer、Sorting Layer、Input Action、Addressables Group、Render Pipeline Asset 是否有规范管理。

### 包管理和项目配置

检查：

- `Packages/manifest.json` 和 `packages-lock.json` 是否提交并一致。
- 是否混入无关包、重复包、临时测试包或本地绝对路径包。
- scoped registry 允许写在 `Packages/manifest.json`。评审重点是 registry 是否属于项目依赖所需、团队和 CI 是否可访问、scope 是否准确、是否错误夹带个人 token、临时账号、本机绝对路径或只在个人电脑可用的地址。
- `ProjectSettings/` 是否完整提交，是否包含和团队规范冲突的编辑器偏好。
- Player Settings、Quality、Graphics、URP/HDRP、Input、Physics、Time、Tags/Layers 是否有明确项目选择。
- 平台相关设置是否集中管理，避免脚本中到处散落平台宏和资源路径。

### Git LFS、gitignore 和仓库治理

检查：

- `.gitignore` 是否使用适合 Unity 的规则，覆盖 `Library/`、`Temp/`、`Obj/`、`Build/`、`Builds/`、`Logs/`、`UserSettings/`、`.vs/`、IDE 缓存和崩溃输出。
- `.gitignore` 是否误忽略 `Assets/**/*.meta`、`ProjectSettings/`、`Packages/manifest.json`、`Packages/packages-lock.json`、源码、asmdef、场景和 Prefab。
- `.gitattributes` 是否配置 Unity YAML 资源、换行规则、merge/diff 策略和 LFS。
- Git LFS 是否覆盖应版本化的大体积二进制资源，例如 `.png`、`.psd`、`.fbx`、`.blend`、`.wav`、`.mp4`、`.exr`、`.tif`、模型、贴图、音频、视频和大型样本数据。
- Git LFS 是否过宽，避免把 `.cs`、`.asmdef`、`.json`、`.unity`、`.prefab`、`.mat` 等需要文本 diff 的资源全部放进 LFS。
- Git 历史中是否已经混入 `Library/`、构建包、日志、大型二进制普通对象、完整未清理插件包、DCC 临时导出或个人工程文件。

### 代码格式化和质量配置

检查：

- 是否存在 `.editorconfig`、Rider/VS 团队规则、dotnet format、csharpier 或团队 C# 格式约定。
- 格式化配置是否和文档、CI、IDE 设置一致。
- 是否有只检查不修改的格式检查入口；没有时记录为质量门禁缺失。
- 是否存在命名、nullable、using 排序、字段序列化、访问修饰符、Unity 生命周期方法顺序等基础规范。
- 是否滥用 `public` 字段代替 `[SerializeField] private`，是否缺少组件引用校验。
- 是否大量使用字符串路径、魔法数字、硬编码资源名、Find/Object 查找和未缓存 GetComponent。

### 静态检查、测试、编译和构建

先判断是否具备可靠自动化入口。Unity 项目没有 batchmode、CI、许可证或目标平台环境时，不要硬上构建。

可检查项：

- EditMode tests、PlayMode tests 是否存在并有运行说明。
- 是否有 Unity Test Framework、CI 命令、batchmode 构建脚本或自定义 BuildPipeline。
- 是否有 Roslyn analyzer、StyleCop、Rider InspectCode、dotnet format、静态代码检查或自定义检查。
- 如有命令入口，再检查测试、脚本编译、资源导入和构建日志；warning 需要记录。
- 没有自动化入口时，重点检查目录、资源、asmdef、测试目录、构建文档、CI 配置和日志产物治理。

不能把未运行的 Unity 构建写成通过。只能写“未执行”，并说明原因。

### Editor 工具和构建发布

检查：

- Editor 工具是否放在 Editor assembly，不进入运行时。
- 自定义菜单、窗口、导入器、构建脚本是否有清晰入口和说明。
- 构建输出路径是否固定到可忽略目录，避免污染仓库。
- 版本号、渠道、平台、资源分包、Addressables profile、签名证书是否有规范管理。
- 构建脚本是否依赖个人绝对路径、本机 Unity Hub 配置或未提交的本地文件。

### 命名、术语和资产规范

检查：

- C# 命名是否符合项目约定，类、接口、枚举、字段、事件、方法、namespace 是否一致。
- 资产命名是否体系化，例如场景、Prefab、材质、贴图、Shader、动画、Timeline、Audio、ScriptableObject。
- 业务术语是否统一，避免旧项目名、模板名、错误业务词残留。
- Tag、Layer、Sorting Layer、Input Action、Addressables Group、Bundle 名称是否有一致规则。
- 文件名、类名、MonoBehaviour 组件名是否一致，避免 Unity 反射和挂载问题。

### Git 历史、文档和提交规范

检查：

- Git 历史中是否有 `Library/`、构建产物、日志、临时资源、个人设置或大体积二进制直接进入普通 Git 对象。
- Git LFS、`.gitignore`、`.gitattributes` 是否和当前资源类型、构建产物、测试产物匹配。
- README、AGENTS、构建文档、资源规范、命名规范是否与当前工程一致。
- Unity 版本、包版本、构建命令、测试命令、目标平台说明是否同步。
- Git 提交信息是否符合正式项目要求，并按 `review-engineering` 与 `/git-commit` 标准检查 subject、body、语言、逻辑单元、历史可追溯性和是否夹带过程噪音。

## 问题分级

- 高：`Assets/` 一级目录评审基线失效、`.meta` 或 ProjectSettings 缺失、Runtime/Editor 混放、asmdef 缺失导致大型项目编译边界失控、Git LFS 规则错误、大体积资源或构建产物污染 Git、完整未清理第三方资产包进入正式仓库、脚本编译或自动化构建存在 warning、测试和构建入口缺失且无说明。
- 中：MonoBehaviour 职责过重、Prefab/场景治理混乱、资源命名不统一、同层目录单复数和大小写体系混乱、美术资源导入和清理流程缺失、Resources 滥用、包配置漂移、格式化配置缺失、gitignore 不完整、文档漂移、提交规范缺失。
- 低：局部命名不一致、个别资源位置不理想、少量配置说明不清。

只写真实问题。没有证据不要写。

## 报告结构和表达要求

沿用 `review-engineering` 的报告结构、问题定性和表达要求，报告标题用 `# <项目名>Unity 工程评审报告`。

必须按 `review-engineering` 的报告落地规则，在项目根目录 `docs/reviews/` 下生成或合并 `YYYY-MM-dd-主题描述.md` 评审报告。

评审范围写清楚：本次只评审 Unity 工程体系、架构规范和风险，不评价功能需求完成度、演示效果或视觉效果。检查情况中列出已执行或无法执行的静态检查、格式检查、脚本编译、EditMode/PlayMode 测试、构建命令及结果。
