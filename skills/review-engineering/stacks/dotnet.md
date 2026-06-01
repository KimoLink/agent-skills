# .NET 工程评审专项清单

本文件是 `review-engineering` 的 .NET 专项清单。使用时先采用 `review-engineering` 的通用工程基线、执行红线、问题定性和报告落地要求，再合并本清单形成一次评审、一次结论和一份 `docs/reviews/` 报告。

## 先确认项目事实

读取：

- 存在的 `AGENTS.md`、README、开发文档、架构文档、部署文档。
- `.sln`、`.slnx`、`.csproj`、`Directory.Build.props`、`Directory.Build.targets`、`Directory.Packages.props`、`global.json`、`NuGet.config`。
- `src/`、`tests/`、`test/`、`samples/`、`tools/`、`build/`、`scripts/`。
- `appsettings*.json`、配置绑定类、日志配置、Dockerfile、compose 文件、发布配置。
- `.editorconfig`、analyzers 配置、StyleCop/Roslynator 配置、coverlet、测试框架配置。
- `.gitignore`、`.gitattributes`、Git LFS 规则。

核对：

- .NET SDK、TargetFramework、LangVersion、Nullable、ImplicitUsings 和文档是否一致。
- 项目类型是 ASP.NET Core API、BFF、后台服务、WPF、WinUI、Avalonia、MAUI、类库、CLI、SDK 还是混合解决方案。
- 包管理是否集中，是否使用 Central Package Management。
- `dotnet format`、build、test、pack、publish 是否有清晰入口。
- 数据库、缓存、消息队列、桌面平台能力、第三方服务或设备接入是否有清晰边界。

## 核心检查项

### 解决方案、项目和包边界

检查：

- `.sln` 或 `.slnx` 是否包含实际参与构建、测试和发布的项目，避免孤立项目和废弃样例混入主解决方案。
- 项目是否按 API/应用层、领域层、基础设施、平台适配、共享类库、测试项目拆分，而不是所有代码堆进单个项目。
- `.csproj` 是否只声明本项目需要的引用、资源、生成器和发布项。
- `Directory.Build.props`、`Directory.Build.targets` 是否集中表达团队规则，避免每个项目重复或互相覆盖。
- `Directory.Packages.props` 或等价机制是否统一包版本，避免项目间包版本漂移。
- 项目引用方向是否清楚，避免 Web/UI 层被领域层反向引用，或测试 helper 进入生产项目。

### Nullable、analyzers 和代码质量配置

检查：

- `Nullable` 是否开启，是否存在大量 `#nullable disable`、`!` 抑制或可空语义失真。
- `TreatWarningsAsErrors`、`WarningsAsErrors`、`.editorconfig`、Roslyn analyzers、StyleCop、代码分析规则是否与项目复杂度匹配。
- 是否存在多套互相冲突的格式化、命名、using 排序和 analyzer 配置。
- source generator、EF Core migration、OpenAPI client、gRPC、Razor、XAML 生成链是否有清晰输入和输出规则。
- `dotnet format --verify-no-changes` 或等价格式检查是否可用；只有自动修复命令时记录为质量门禁缺失。

### DI、配置、日志和横切能力

检查：

- DI 注册是否集中、可追踪，避免在入口文件堆积大量无分组注册或隐藏 service locator。
- Service 生命周期是否合理，避免 singleton 持有 scoped 服务、DbContext、HttpClient 或 UI 对象。
- 配置是否通过 options pattern、配置绑定和校验表达，避免硬编码连接串、外部地址、密钥、本机路径。
- `.env`、user secrets、Key Vault、环境变量、`appsettings.*.json` 的职责是否清楚，仓库中不应包含真实密钥。
- 日志是否使用统一抽象，结构化字段、trace id、请求日志、业务日志和错误日志是否区分。
- 异常处理、鉴权授权、审计、健康检查、限流、重试、超时是否有集中入口。

### ASP.NET Core、后台服务和外部依赖

适用于服务端项目时检查：

- `Program.cs` 是否只负责组合和启动，不承担业务流程。
- Controller、Minimal API endpoint、middleware、filter、handler 是否只处理传输层职责。
- DTO、领域模型、数据库实体、ViewModel、消息契约是否分清。
- EF Core、Dapper、HTTP client、消息队列、缓存、文件存储、第三方 SDK 是否集中封装。
- migration、seed、fixture、数据库初始化和事务边界是否有明确目录和执行说明。
- HostedService、Worker、定时任务、消费端是否有取消、重试、幂等、观测和停机处理。

### 桌面端、UI 和平台适配

适用于 WPF、WinUI、Avalonia、MAUI 或桌面端项目时检查：

- View、ViewModel、Model、Service、平台适配是否分层清楚。
- 界面代码是否直接访问数据库、网络、设备 SDK 或复杂业务流程。
- XAML、资源字典、主题、样式、控件模板、图标、字体和本地化资源是否有稳定目录和命名规则。
- UI 线程、后台任务、事件聚合、命令、绑定、生命周期是否有清晰约束。
- 平台差异、权限、签名、安装包、自动更新和本地数据目录是否集中管理。

### 测试体系

检查：

- 测试项目是否按单元测试、集成测试、契约测试、UI/端到端测试或性能测试区分。
- 测试命名、fixture、mock、testcontainers、WebApplicationFactory、临时数据库、文件系统替身是否有固定规则。
- 测试是否污染真实数据库、外部服务、本地用户目录或设备环境。
- coverage、trx、TestResults、bin/obj、快照和临时文件是否进入专用目录并被忽略。
- 关键业务规则、配置绑定、DI 组合、数据库访问和外部服务错误路径是否有测试入口。

### 包管理、仓库治理和发布产物

检查：

- `NuGet.config` 是否夹带个人源、token、代理、本机证书路径或只属于某一环境的配置。
- `packages.lock.json`、central package management、restore locked mode 是否与团队要求一致。
- `.gitignore` 是否覆盖 `bin/`、`obj/`、`TestResults/`、coverage、publish、artifacts、logs、`.vs/`、Rider 缓存、本地数据库和用户密钥。
- `.gitignore` 是否误忽略源码、`.csproj`、`.sln`、配置样例、migration、测试 fixture、资源字典或发布脚本。
- `.gitattributes` 是否处理换行规范、二进制资源和 LFS 规则。
- Git LFS 是否只用于确实需要版本化的大体积样本、安装包基线、模型或二进制资源；不要把源码、项目文件、普通 JSON、migration 或锁文件放进 LFS。
- 发布输出、安装包、NuGet 包、日志、崩溃 dump、profile 和临时数据是否污染仓库。

### 格式检查、构建和测试

优先查 README、脚本和解决方案结构，再按项目事实运行或记录缺失：

- 格式检查：`dotnet format --verify-no-changes` 或项目等价脚本。
- 构建：`dotnet build`，项目要求时使用 `-warnaserror` 或对应配置。
- 测试：`dotnet test`，必要时指定解决方案、测试项目或过滤条件。
- 打包发布：`dotnet pack`、`dotnet publish` 或平台安装包脚本。

如果只有格式化修复命令没有 verify/check 入口，记录为质量门禁缺失。
如果 build、test、pack 或 publish 无法执行，说明原因，不写成通过。

### 命名、文档和提交规范

检查：

- namespace、项目名、程序集名、类、接口、DTO、Options、Handler、Service、Repository、ViewModel、Command、Event 命名是否统一。
- 文件命名、目录命名和 namespace 是否一致。
- 业务术语是否统一，避免旧项目名、模板名、错误业务词残留。
- README、已存在的 AGENTS、部署文档、接口文档、桌面端打包文档是否与当前工程一致。
- .NET SDK、TargetFramework、数据库 migration、构建命令、测试命令、发布命令是否同步。
- Git 提交信息是否符合正式项目要求，并按 `review-engineering` 与 `/git-commit` 标准检查 subject、body、语言、逻辑单元、历史可追溯性和是否夹带过程噪音。

## 专项分级

- 高：解决方案项目边界失控、Nullable/analyzers 关闭或被大范围绕过、DI 生命周期错误、配置和密钥治理失效、build/test 不可用、编译 warning、服务或 UI 层直连基础设施导致架构倒置、bin/obj/publish/TestResults 或敏感配置污染仓库。
- 中：项目引用方向混乱、DTO/实体/ViewModel 混用、日志和异常处理不统一、测试项目缺失或边界不清、包版本漂移、格式化配置冲突、gitignore 或 LFS 规则不完整、文档漂移、提交规范缺失。
- 低：局部命名不一致、个别文件位置不理想、少量配置说明不清。

## 报告补充

沿用 `review-engineering` 的报告结构、问题定性和表达要求，报告标题用 `# <项目名>.NET 工程评审报告`。

评审范围写清楚：本次只评审 .NET 工程体系、解决方案边界、质量门禁、测试体系和风险，不评价功能需求完成度、业务规则正确性或界面效果。检查情况中列出已执行或无法执行的 `dotnet format`、`dotnet build`、`dotnet test`、打包发布命令及结果。
