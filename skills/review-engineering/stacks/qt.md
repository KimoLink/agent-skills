# Qt 工程评审专项清单

本文件是 `review-engineering` 的 Qt 专项清单。使用时先采用 `review-engineering` 的通用工程基线、执行红线、问题定性和报告落地要求，再合并本清单形成一次评审、一次结论和一份 `docs/reviews/` 报告。

## 先确认项目事实

读取：

- 存在的 `AGENTS.md`、README、开发文档、构建文档、打包文档、设备接入说明。
- `CMakeLists.txt`、`cmake/`、工具链文件、`.pro`、`.pri`、`vcpkg.json`、`conanfile.*`。
- `.ui`、`.qrc`、QML 文件、`qmldir`、翻译文件、资源目录。
- `src/`、`include/`、`app/`、`widgets/`、`qml/`、`core/`、`services/`、`drivers/`、`platform/`、`tests/`。
- `.clang-format`、`.clang-tidy`、`.editorconfig`、测试配置、打包脚本。
- `.gitignore`、`.gitattributes`、Git LFS 规则。

核对：

- Qt 版本、C++ 标准、编译器、目标平台和文档是否一致。
- 项目是 Qt Widgets、QML/Qt Quick、混合 UI、桌面客户端、嵌入式界面、设备控制台还是内部工具。
- 构建系统是 CMake 还是 qmake，是否存在两套并行且无人维护的构建入口。
- 是否有自动化测试、静态检查、格式检查、平台打包或团队构建说明。
- 是否依赖专用硬件、串口、相机、PLC、仪器、驱动、平台插件或私有 SDK。

## 核心检查项

### 构建系统和 Qt 生成链

检查：

- CMake Qt 项目是否正确配置 `AUTOMOC`、`AUTOUIC`、`AUTORCC` 或显式调用对应 Qt helper。
- Qt 模块依赖是否准确声明，避免把 Widgets、QML、Network、Sql、SerialPort、Charts 等模块全局滥加。
- qmake 项目中 `.pro/.pri` 是否按模块拆分清楚，避免所有源码、资源和平台宏堆在一个文件里。
- `moc`、`uic`、`rcc` 生成文件是否不进入源码目录和版本库。
- Debug/Release、平台、编译器、Qt 安装路径、第三方库路径是否通过工具链或环境配置管理，不写死个人绝对路径。
- CMake/qmake、IDE 工程和文档命令是否一致，避免文档写一套、实际维护另一套。

### UI、业务和设备适配边界

检查：

- `MainWindow`、Dialog、Widget、QML Page 是否只负责界面组合、输入输出和状态展示，不直接承担复杂业务流程或设备协议。
- 业务逻辑、设备通信、数据模型、配置、缓存、日志、平台适配是否有独立模块。
- UI 层是否直接操作串口、网络 socket、数据库、文件系统或硬件 SDK。
- Model/View、ViewModel、Controller、Service 等边界是否符合项目约定，不把模型、控件和设备状态混成一个类。
- QML 项目中 C++ backend、context property、singleton、QML module 和 JavaScript helper 是否有清楚职责。
- 平台差异是否集中在 adapter 或 platform 层，避免平台宏散落在 UI 文件和业务类中。

### 线程、信号槽和对象生命周期

检查：

- 长耗时任务、设备 IO、网络请求、图像处理、数据库操作是否避免阻塞 UI 线程。
- `QThread`、worker object、thread affinity、`moveToThread`、连接类型和对象销毁是否清楚。
- 信号槽是否表达明确事件，不用跨层大范围串联替代模块接口。
- 是否存在 lambda 捕获悬空对象、跨线程直接访问 QObject、父子对象生命周期混乱、事件循环嵌套滥用。
- 共享状态是否有同步策略，避免 UI、worker、设备回调同时读写。
- 错误、取消、超时、重连和资源释放路径是否可追踪。

### Widgets、QML、资源和翻译

检查：

- `.ui` 文件、手写 Widget、样式表和业务逻辑是否分层清楚。
- QML 页面、组件、状态、动画、主题 token 和资源引用是否有稳定目录和命名规则。
- `.qrc` 是否只收纳需要打包进资源系统的文件，避免把临时素材、源设计稿和大体积样本塞进资源。
- 图片、图标、字体、翻译、样式表、QML module 是否有清楚版本和来源。
- 翻译文件、`lupdate`、`lrelease` 和语言包加载流程是否有说明。
- 主题、样式表、QML 全局样式和局部控件样式是否互相覆盖失控。

### 第三方依赖、平台插件和打包发布

检查：

- Qt runtime、平台插件、图形后端、OpenSSL、数据库驱动、串口驱动、相机 SDK、私有 DLL/so/dylib 是否有来源和版本说明。
- Windows、macOS、Linux、嵌入式平台的打包脚本是否清楚，例如 `windeployqt`、`macdeployqt`、AppImage、deb/rpm、MSIX、安装器或自定义脚本。
- 签名证书、安装路径、配置文件、日志目录和升级策略是否区分开发环境与发布环境。
- 第三方二进制是否有合理落位和忽略规则，避免把本机 Qt 安装目录、完整 SDK 或 IDE 缓存提交进仓库。
- 平台打包产物、日志、崩溃 dump 和临时部署目录是否被忽略。

### Git LFS、gitignore 和仓库治理

检查：

- `.gitignore` 是否覆盖 CMake/qmake 构建目录、生成文件、IDE 缓存、Qt Creator 用户文件、部署输出、日志、coverage、临时资源和本地配置。
- `.gitignore` 是否误忽略源码、头文件、`.ui`、`.qrc`、QML、翻译源、构建脚本、测试 fixture 或必要资源。
- `.gitattributes` 是否处理换行规范、二进制资源和 LFS 规则。
- Git LFS 是否只用于确实需要版本化的大体积资源，例如设计导出、模型、样本数据、安装包基线或私有二进制；不要把源码、`.ui`、`.qrc`、QML、CMake 配置或普通 JSON/XML 放进 LFS。
- Git 历史中是否有 build 目录、部署包、Qt 安装目录、IDE 用户文件、日志或本地设备配置污染。

### 静态检查、格式检查、构建和测试

先判断项目是否具备可靠命令和环境。依赖专用设备、驱动、平台 SDK 或签名证书时，不要把无法执行的完整验证写成通过。

可检查项：

- 格式检查：clang-format check、项目脚本或团队约定命令。
- 静态检查：clang-tidy、cppcheck、Qt Creator Clang Tools 或项目脚本。
- 构建：CMake configure/build、qmake/make、Ninja、MSBuild 或项目脚本。
- 测试：Qt Test、Catch2、GoogleTest、CTest、集成测试或设备替身测试。
- 打包：平台部署脚本、安装器生成或发布说明。

如果只有自动修复命令没有 check 入口，记录为质量门禁缺失。
如果构建、测试或打包无法执行，说明原因，不写成通过。

### 命名、文档和提交规范

检查：

- 类、文件、namespace、QObject、Widget、QML 组件、资源、信号槽、配置键、设备协议字段命名是否统一。
- 业务术语是否统一，避免旧项目名、模板名、错误业务词残留。
- README、已存在的 AGENTS、构建文档、打包文档、设备接入说明是否与当前工程一致。
- Qt 版本、C++ 标准、构建命令、测试命令、部署命令、目标平台说明是否同步。
- Git 提交信息是否符合正式项目要求，并按 `review-engineering` 与 `/git-commit` 标准检查 subject、body、语言、逻辑单元、历史可追溯性和是否夹带过程噪音。

## 专项分级

- 高：UI 层直连设备或数据库、线程模型导致 UI 阻塞或跨线程访问风险、构建入口不可用、编译 warning、moc/uic/rcc 生成链失控、本机绝对路径或私有 SDK 配置污染仓库、打包产物或 Qt 安装目录进入 Git。
- 中：Widgets/QML 职责过重、信号槽跨层滥用、资源和翻译规则缺失、平台适配散落、格式化和静态检查缺失、gitignore 或 LFS 规则不完整、文档漂移、提交规范缺失。
- 低：局部命名不一致、个别文件位置不理想、少量配置说明不清。

## 报告补充

沿用 `review-engineering` 的报告结构、问题定性和表达要求，报告标题用 `# <项目名>Qt 工程评审报告`。

评审范围写清楚：本次只评审 Qt 工程体系、UI/业务/设备适配边界、线程模型、构建打包和风险，不评价功能需求完成度、界面效果或单个交互 bug。检查情况中列出已执行或无法执行的格式检查、静态检查、构建、测试、打包命令及结果。
