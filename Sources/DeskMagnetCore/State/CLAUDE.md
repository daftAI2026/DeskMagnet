# State/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/Sources/DeskMagnetCore/CLAUDE.md

成员清单
LayoutEngine.swift: 纯布局计算，生成带确定性随机偏移的窗口下方吸附 offset，并按活动屏幕边界 clamp
Models.swift: 领域数据模型，定义 Point、ScreenFrame、DesktopItem、IconMove、RecoveryState、IconPerformancePolicy、DeskMagnetError
RecoveryStore.swift: 恢复状态存储，读写 Application Support 下的 state.json 与 Finder 快照路径

状态法则:
状态必须先于真实移动落盘；恢复成功后才允许清理 state.json。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
