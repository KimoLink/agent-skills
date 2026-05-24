## 语言与沟通

始终使用中文回复。需要推理时先想清楚步骤，再给出结论。

回答必须贴近当前任务，少说空话；不隐藏问题，不把未验证状态说成已完成。

## 行为原则

遇到不确定的问题，先搜索或查证再动手。代码类问题优先使用 context7 获取最新官方文档或库文档。

遇到问题不要停留在打补丁式处理，要从结构、边界和风险上系统审视，优先解决根因。

除规划、短线问答和主会话必须立即处理的阻塞步骤外，非短线任务必须先拆给子智能体执行。非短线任务包括跨多个文件的实现或修复、需要连续调试/验证的功能完善、功能层面审查后的推进，以及预计需要超过一轮工具调用才能闭环的工作。

主会话负责明确任务边界、分配互不冲突的写入范围、监督进度、审查 diff、整合结果、最终验证、提交和后续规划。主会话不得在适合拆分的任务上长期自行实现；如果发现自己正在连续读改测同一非短线任务，必须停止并补派子智能体接手。

允许不派子智能体的情况只有：用户明确要求不要使用子智能体；任务只是只读规划或短问答；当前步骤是主会话必须立即处理的阻塞点；或子智能体工具不可用。使用例外时必须说明原因。

工作完成后，主动判断当前变更是否形成清晰、完整、可交付的逻辑单元。适合提交时，优先使用 `git-commit` skill，并按仓库既有提交风格完成提交；任务仍处于中间态、缺少必要验证，或用户明确不希望提交时，不要提交。

## 文档规范

Markdown 文档标题禁止使用序号；其他格式不限，但不要过度滥用格式。

专业文档默认使用正向表述，优先写“负责什么、形成什么、支撑什么、推进什么、纳入什么管理”。不要把方案、规划、制度写成“不是、不再、不直接、不代表、不建议、不作为、不宜、避免”堆出来的排除清单。

否定表述只用于硬性禁止、风险提示、法律边界或安全边界。涉及不推进、不纳入、不适合的内容，应改写为准入条件、优先级规则、后续评估条件或风险提示，不得作为段落主叙述。

## 开发规范

修改文件前必须先尊重仓库已有格式配置，尤其是 `.editorconfig`、`.gitattributes` 和同类文件的现有行尾风格。不要仅凭 `git diff --check`、个人 `core.autocrlf` 或通用经验改动 CRLF/LF；如果 `.editorconfig` 已声明 `end_of_line = crlf`，对应文件必须保持 CRLF。需要规范化行尾时，必须作为独立格式治理任务处理，并先说明影响范围。

### C#

修改 C# 文件前必须先查看仓库的 `.editorconfig`、`.csharpierrc*`、`.csharpierignore`、dotnet tool manifest 等格式配置，不能凭个人习惯手写排版。

C# 格式统一以 CSharpier 为准。每次修改 C# 文件后，必须对本次改动的 `.cs` 文件执行 CSharpier 格式检查；优先使用仓库本地 tool manifest，必要时再使用环境中已有的 `dotnet csharpier` 命令。

```powershell
dotnet csharpier check <changed-cs-files>
```

如果 CSharpier 检查失败，应先用 CSharpier 格式化本次改动文件，再重新执行检查。

```powershell
dotnet csharpier format <changed-cs-files>
dotnet csharpier check <changed-cs-files>
```

CSharpier 只代表格式检查/格式化，不代表编译、测试或运行验证；不得把 CSharpier 通过说成项目已编译或 Unity 已验证。如果仓库未配置 CSharpier 或当前环境缺少命令，必须如实说明，不得用其他格式化工具冒充。

CSharpier 负责格式，`.editorconfig` 中的命名、可见性、readonly 等 analyzer 规则仍需单独遵守。Unity 项目中涉及 `[SerializeField]` 的字段也必须强制按规范命名，不因序列化兼容性放宽命名规则。

### Node.js

禁止使用 npm，必须使用 bun。

### Unity

Unity 项目禁止使用 `dotnet build`、`msbuild` 或直接编译 Unity 生成的 `.csproj` / `.sln` 作为验证方式；不要把这类外部编译结果说成 Unity 项目已验证，Unity 官方也不支持用这种方式替代 Editor 内编译、导入、测试或构建。

不得为了让外部编译通过而修改 Unity 生成的 `.csproj`、`.sln`、`Library/`、`Temp/` 或其他本地生成产物。不得主动查找 Unity Editor 安装目录、启动 Unity Editor、操作 Unity Editor 图形界面，或把 Unity Editor 作为常规验证步骤；Unity Editor 交互验证由用户负责。

只有用户明确要求执行 Unity 验证，或项目提供已确认的非交互式 Unity Test Framework、batchmode、BuildPipeline 等自动化入口且当前任务明确需要时，才可以运行对应 Unity 自动化命令。执行前必须说明验证入口、影响范围和生成产物风险；如果未执行 Unity 验证，只能如实说明未执行，并改用文本扫描、资源/YAML 一致性检查、`git diff --check`、目标脚本或项目已有静态检查作为辅助，不得冒充完整验证。

### Rust

完成代码修改后，必须执行 `cargo fmt --all` 和 `cargo clippy --all-targets --all-features -- -D warnings`；如无必要，禁止使用 `#[allow(...)]` 屏蔽警告。

除 `cargo fmt --all` 外，`cargo check`、`cargo clippy`、`cargo test`、`cargo build`、`cargo run`、`cargo doc` 等会写入 `target` 或运行 build script 的命令，必须直接申请非沙箱执行；原因写明：沙箱可能导致构建产物写入失败，例如 `拒绝访问 (os error 5)`。

禁止使用 `CARGO_TARGET_DIR` 绕开 Cargo 构建产物写入问题。
