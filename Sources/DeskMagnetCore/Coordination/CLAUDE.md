# Coordination/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/Sources/DeskMagnetCore/CLAUDE.md

成员清单
AppCoordinator.swift: P1 应用编排，串联 Finder 兼容模式、状态落盘、批量移动、恢复清理
P0Workflow.swift: P0 技术验证编排，串联兼容模式、读取、移动、恢复

编排法则:
流程层只排序步骤和兜底恢复，不生成 AppleScript，不直接读写 JSON。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
