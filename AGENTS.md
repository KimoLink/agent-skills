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

## 开发规范

修改文件前必须先查看并尊重仓库已有格式配置，包括 `.editorconfig`、`.gitattributes` 和同类文件。

行尾风格以仓库配置为准。不要仅凭个人 `core.autocrlf`、通用经验或检查命令输出改动 CRLF/LF；如果 `.editorconfig` 已声明 `end_of_line = crlf`，对应文件必须保持 CRLF。

需要规范化行尾时，必须作为独立格式治理任务处理，并先说明影响范围。

### C#

修改 C# 文件前必须先查看仓库的 `.editorconfig`、`.csharpierrc*`、`.csharpierignore` 等格式配置，不能凭个人习惯手写排版。

C# 格式统一以 CSharpier 为准。每次修改 C# 文件后，必须对本次改动的 `.cs` 文件执行 CSharpier 格式检查。

```powershell
csharpier check <changed-cs-files>
```

如果 CSharpier 检查失败，应先用 CSharpier 格式化本次改动文件，再重新执行检查。

```powershell
csharpier format <changed-cs-files>
csharpier check <changed-cs-files>
```

CSharpier 只代表格式检查/格式化，不代表编译、测试或运行验证。如果当前环境缺少 `csharpier` 命令，必须如实说明，不得用其他格式化工具冒充。

CSharpier 负责格式，`.editorconfig` 中的命名、可见性、readonly 等 analyzer 规则仍需单独遵守。Unity 项目中涉及 `[SerializeField]` 的字段也必须强制按规范命名，不因序列化兼容性放宽命名规则。

### Node.js

Node.js 项目必须使用 bun。

禁止使用 npm，包括 `npm install`、`npm run`、`npx` 和会生成 `package-lock.json` 的命令。

如仓库已有脚本或文档仍写 npm，优先换成等价 bun 命令；不要顺手引入新的包管理器锁文件。

### Unity

禁止启动 Unity Editor，包括图形界面、`Unity.exe -batchmode`、Unity Test Framework batchmode、BuildPipeline，或任何会打开、导入、锁定、写入 Unity 项目 `Library` 的 Editor 进程。

禁止查找 Unity Editor 安装位置、探测 Unity 进程，或为了验证而准备启动 Unity Editor。

禁止使用 `dotnet build`、`msbuild` 或直接编译 Unity 生成的 `.csproj` / `.sln` 作为验证方式。

禁止为了让外部编译通过而修改 Unity 生成的 `.csproj`、`.sln`、`Library/`、`Temp/` 或其他本地生成产物。

涉及 C# 改动时，按 C# 规则执行 CSharpier 格式检查。

可按任务需要执行文本扫描、资源/YAML 一致性检查、引用检查、目标脚本或项目已有静态检查。

### Rust

完成 Rust 代码修改后，必须执行：

```powershell
cargo fmt --all
cargo clippy --all-targets --all-features -- -D warnings
```

如无必要，禁止使用 `#[allow(...)]` 屏蔽警告。

禁止使用 `CARGO_TARGET_DIR` 绕开 Cargo 构建产物写入问题。

如果 Cargo 命令因 Windows 文件锁、权限或构建产物写入失败受阻，应如实报告阻断原因和具体命令，不要改用外部目标目录掩盖问题。
