# State/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/Sources/DeskMagnetCore/CLAUDE.md

成员清单
DesktopCoordinateConverter.swift: 坐标系转换，将 AppKit 左下角窗口/屏幕坐标转成 Finder 左上角桌面坐标
LayoutEngine.swift: 纯布局计算，把 Finder 图标锚点压进窗口内部安全区并确定性散布，由桌面层天然 Z 轴遮盖
Models.swift: 领域数据模型，定义 Point、ScreenFrame、DesktopItem、带 path 身份的 IconMove、RecoveryStateStatus、RecoveryState、IconPerformancePolicy、DeskMagnetError
RecoveryStore.swift: 恢复状态存储，读写 Application Support 下的 state.json 与 Finder 快照路径

状态法则:
状态必须先于真实移动落盘；状态读取失败必须显形；恢复完成或部分恢复后才允许清理 state.json。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
