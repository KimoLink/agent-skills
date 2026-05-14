---
name: review-rust
description: Use when 用户要求对 Rust 后端、CLI、库、SDK、workspace、异步服务、系统工具或 Rust 混合仓库做工程级评审、crate 边界审查、依赖治理审查或 Rust 工程质量审查；不要用于普通接口功能验收、业务规则评审、性能效果评价或只检查某个 bug。
---

# Rust 工程评审

## 定位

这是 Rust 项目的工程级评审流程。它是 `review-engineering` 的 Rust 专项版本，重点看 Cargo workspace、crate 边界、features、错误处理、async、unsafe、依赖治理、fmt/clippy/test/build、仓库治理和长期维护风险，不做业务功能验收或单点 bug 排查。

评审对象包括 `Cargo.toml`、workspace 配置、crate 边界、features、错误处理、async runtime、unsafe、依赖治理、`cargo fmt`、`cargo clippy`、`cargo test`、`cargo build`、文档同步和提交规范。

**REQUIRED SUB-SKILL:** 先阅读并采用 `review-engineering` 的通用工程基线。

## 使用方式

- 先采用 `review-engineering` 的通用基线、执行红线、问题定性和报告落地要求。
- 再使用本 skill 的 Rust 专项清单补充检查；最终只输出一次评审、一次结论和一份报告。
- 不把二进制能启动、接口能返回或示例能跑通当成工程合格。
- clippy warning、编译 warning、测试 warning 和 build script warning 要作为风险记录。

## 用户环境硬性规则

修改 Rust 代码后，必须执行：

- `cargo fmt --all`
- `cargo clippy --all-targets --all-features -- -D warnings`

除 `cargo fmt --all` 外，`cargo check`、`cargo clippy`、`cargo test`、`cargo build`、`cargo run`、`cargo doc` 等会写入 `target` 或运行 build script 的命令，必须直接申请非沙箱执行；原因写明：沙箱可能导致构建产物写入失败，例如 `拒绝访问 (os error 5)`。

禁止使用 `CARGO_TARGET_DIR` 绕开 Cargo 构建产物写入问题。

评审时如果只是只读检查，优先使用 `cargo fmt --all -- --check`。如果从评审转入修复，上述修改后验证规则必须执行并在交付说明中写清楚结果。

## 先确认项目事实

读取：

- 存在的 `AGENTS.md`、README、开发文档、架构文档、发布文档。
- `Cargo.toml`、workspace 根配置、各 crate 的 `Cargo.toml`、`Cargo.lock`。
- `rust-toolchain.toml`、`rustfmt.toml`、`clippy.toml`、`.cargo/config.toml`。
- `src/`、`crates/`、`bins/`、`examples/`、`tests/`、`benches/`、`xtask/`、`build.rs`。
- Dockerfile、compose 文件、部署脚本、release 配置、跨编译配置。
- `.gitignore`、`.gitattributes`、Git LFS 规则。

核对：

- Rust toolchain、edition、MSRV、target、features 和文档是否一致。
- 项目类型是后端服务、CLI、库、SDK、workspace、嵌入式、桌面/GUI、WASM 还是混合仓库。
- 是否使用 tokio、async-std、actix、axum、tonic、serde、sqlx、diesel、tauri、wasm-bindgen 等关键依赖。
- fmt、clippy、test、build、doc、bench、release 是否有清晰入口。
- 是否存在 build script、proc macro、native dependency、跨编译或平台 SDK 约束。

## 核心检查项

### Cargo workspace 和 crate 边界

检查：

- workspace members、default-members、resolver、package metadata 是否和实际项目一致。
- crate 是否按领域、接口适配、基础设施、CLI、服务端入口、共享库、测试工具拆分。
- `src/main.rs`、`src/lib.rs`、bin target 是否只负责组合和启动，不承担大量业务逻辑。
- crate 之间依赖方向是否清楚，避免基础 crate 反向依赖应用层或测试工具进入生产路径。
- workspace dependency、workspace lints、profile、patch、replace 是否集中且有理由。
- examples、benches、tests、xtask 是否有明确用途，不把临时代码混入正式 crate。

### features、配置和条件编译

检查：

- features 是否表达真实可选能力，避免默认启用过多重依赖或把环境开关塞进 feature。
- default features 是否克制，库 crate 是否避免默认引入重 runtime、TLS、数据库或平台依赖。
- feature 组合是否可构建，是否存在互斥 feature 未声明或未测试。
- `cfg`、target-specific dependencies、平台宏是否集中管理，避免散落到业务逻辑。
- `.cargo/config.toml` 是否包含只属于个人环境的 registry、代理、target、linker 或路径配置。
- 配置、环境变量、命令行参数和 secrets 是否有类型化解析和校验，不硬编码本机路径、token 或服务地址。

### 错误处理、类型边界和 API 契约

检查：

- 库 crate 是否暴露稳定错误类型，避免把 `anyhow::Error`、内部错误或第三方错误直接扩散到公共 API。
- 应用层是否合理使用 `anyhow`，库层是否优先使用 `thiserror` 或明确错误枚举。
- `unwrap`、`expect`、`panic!` 是否限制在测试、初始化不可恢复路径或有清楚说明的断言。
- DTO、领域模型、持久化模型、协议模型、CLI 参数和配置模型是否分清。
- serde schema、OpenAPI、protobuf、SQL migration、消息契约是否和代码同步。
- 公开 API、trait、泛型、生命周期和所有权边界是否为调用方可理解，而不是把内部复杂度泄漏出去。

### async、并发和资源生命周期

检查：

- async runtime 是否单一且边界清楚，避免 tokio、async-std、actix runtime 混用。
- 阻塞 IO、CPU 密集任务、数据库连接、文件操作和外部命令是否避免阻塞 async executor。
- channel、mutex、RwLock、Arc、task spawn、取消、超时、重试、backpressure 是否有清楚策略。
- 后台任务、信号处理、graceful shutdown、连接池、事务和临时文件生命周期是否可追踪。
- 日志、trace id、metrics、health check 和错误上下文是否能支持线上定位。

### unsafe、FFI 和平台依赖

检查：

- `unsafe` 是否集中、最小化，并写清楚安全前提；不要用 `#[allow(unsafe_code)]` 或大范围允许规则掩盖风险。
- FFI、bindgen、C ABI、native library、linker、平台 SDK 是否有版本、来源和构建说明。
- build script 是否可复现，不依赖个人绝对路径、未提交文件、临时下载或本机环境。
- 跨平台路径、换行、权限、编码、时区、信号、动态库加载是否有明确适配层。
- unsafe 封装是否有测试、文档或属性验证，避免把不安全前提交给调用方猜测。

### 依赖治理、仓库治理和产物治理

检查：

- `Cargo.lock` 是否按项目类型提交：应用、CLI、服务端和 workspace 通常应提交；纯库按团队规范判断并说明。
- 依赖是否重复、过重、长期未维护或功能重叠，例如多个 HTTP client、日志库、错误处理库、async runtime。
- 是否使用 git/path dependency、patch、私有 registry；若使用，来源、版本和团队可访问性是否清楚。
- `.gitignore` 是否覆盖 `target/`、coverage、profiling、logs、临时数据库、生成文件、本地 `.env` 和 IDE 缓存。
- `.gitignore` 是否误忽略源码、`Cargo.lock`、migration、schema、测试 fixture、协议文件或生成输入。
- `.gitattributes` 是否处理换行规范、二进制资源和 LFS 规则。
- Git LFS 是否只用于确实需要版本化的大体积样本、模型、测试数据或二进制资源；不要把源码、Cargo 配置、锁文件、普通 JSON/TOML 放进 LFS。
- Git 历史中是否有 `target/`、profile、coverage、日志、临时数据库、密钥或大体积二进制普通对象污染。

### fmt、clippy、test、build 和 doc

优先查 README、脚本和 workspace 配置，再按项目事实运行或记录缺失：

- 格式检查：只读评审优先 `cargo fmt --all -- --check`。
- 静态检查：`cargo clippy --all-targets --all-features -- -D warnings`。
- 测试：`cargo test --all-targets --all-features` 或项目脚本。
- 构建：`cargo build --all-targets --all-features` 或项目脚本。
- 文档：`cargo doc --all-features --no-deps` 或项目脚本，适用于库、SDK 或公共 API 项目。

如果 features 组合过多，应说明实际检查的 feature 集合和未覆盖范围。
如果命令无法执行，说明原因，不写成通过。

执行 `cargo check`、`cargo clippy`、`cargo test`、`cargo build`、`cargo run`、`cargo doc` 等命令时，遵守用户环境硬性规则：直接申请非沙箱执行，不能用 `CARGO_TARGET_DIR` 绕开。

### 命名、文档和提交规范

检查：

- crate、module、trait、struct、enum、error、feature、bin、command、配置键、环境变量命名是否统一。
- 文件命名、模块命名和公开 API 命名是否符合 Rust 习惯和项目约定。
- 业务术语是否统一，避免旧项目名、模板名、错误业务词残留。
- README、已存在的 AGENTS、架构文档、API 文档、部署文档、CLI help 是否与当前代码一致。
- Rust toolchain、features、构建命令、测试命令、发布命令和环境要求是否同步。
- Git 提交信息是否符合正式项目要求，并按 `review-engineering` 与 `/git-commit` 标准检查 subject、body、语言、逻辑单元、历史可追溯性和是否夹带过程噪音。

## 专项分级

- 高：crate 边界失控、features 组合不可构建、clippy 或编译 warning、unsafe 无安全前提、build script 依赖个人环境、错误处理泄漏内部实现、async runtime 混乱、测试或构建入口不可用、`target/`、密钥或大体积产物污染仓库。
- 中：默认 features 过重、依赖重复或漂移、`unwrap/expect` 扩散、配置缺少类型校验、文档命令漂移、格式化配置缺失、gitignore 或 LFS 规则不完整、提交规范缺失。
- 低：局部命名不一致、个别模块位置不理想、少量配置说明不清。

## 报告补充

沿用 `review-engineering` 的报告结构、问题定性和表达要求，报告标题用 `# <项目名>Rust 工程评审报告`。

评审范围写清楚：本次只评审 Rust 工程体系、crate 边界、依赖治理、质量门禁和风险，不评价功能需求完成度、业务规则正确性或单个 bug。检查情况中列出已执行或无法执行的 `cargo fmt`、`cargo clippy`、`cargo test`、`cargo build`、`cargo doc` 命令及结果，并说明是否因沙箱、target 写入或 build script 限制未执行。
