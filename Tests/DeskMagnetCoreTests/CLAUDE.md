# DeskMagnetCoreTests/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/Tests/CLAUDE.md

成员清单
AppCoordinatorTests.swift: 验证 P1 编排层的吸附、恢复、启动未恢复状态检测
FinderIconControllerTests.swift: 验证 AppleScript 转义、批量移动脚本和坐标多数有效规则
LayoutEngineTests.swift: 验证窗口下方吸附布局与 offset 复用移动
P0WorkflowTests.swift: 验证 P0 失败路径仍执行 Finder 设置恢复
RecoveryStoreTests.swift: 验证 state.json 写入、读取、清理

测试边界:
不直接操作 Finder；所有系统命令通过 RecordingShellRunner 捕获。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
