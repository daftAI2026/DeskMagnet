# State/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/Sources/DeskMagnetCore/CLAUDE.md

成员清单
LayoutEngine.swift: 纯布局计算，生成窗口下方吸附 offset、跟随移动与原位恢复 moves
Models.swift: 领域数据模型，定义 Point、DesktopItem、IconMove、P0Snapshot、RecoveryState、DeskMagnetError
RecoveryStore.swift: 恢复状态存储，读写 Application Support 下的 state.json 与 Finder 快照路径

状态法则:
状态必须先于真实移动落盘；恢复成功后才允许清理 state.json。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
