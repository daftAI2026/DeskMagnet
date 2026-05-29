# Sources/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/CLAUDE.md

成员清单
DeskMagnetCore/: P0 领域核心，封装 Finder 设置、桌面图标与命令执行边界
DeskMagnetCLI/: 命令行入口，暴露真实 Finder 验证流程

模块边界:
DeskMagnetCLI 只能编排用户命令与输出；Finder 自动化、坐标校验、恢复策略必须下沉到 DeskMagnetCore。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
