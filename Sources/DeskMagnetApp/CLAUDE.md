# DeskMagnetApp/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/Sources/CLAUDE.md

成员清单
AppDelegate.swift: AppKit 生命周期，创建固定 800x520 full-size 亮色主窗口、应用菜单、禁用位置恢复并居中到主屏、让系统三按钮落入绿色顶栏、转换 Finder 顶左坐标、关闭时自动恢复、启动未恢复状态检测
AppLocalization.swift: 本地化单一真相源，固定“桌面清理大师”软件名，维护系统语言默认值、用户语言选择和中繁英日韩五套窗口/菜单文案
ContentView.swift: SwiftUI 内容区，以单一绿色主色、1:4 顶栏/主体分区呈现本地化“桌面清理大师”工具面板，不暴露吸附实现
DeskMagnetAppMain.swift: NSApplication 入口，设置 delegate 并启动事件循环
DeskMagnetViewModel.swift: 主窗口状态模型，调用 AppCoordinator 执行吸附、关闭恢复、跟随同步并按当前语言呈现错误
WindowFollowController.swift: 监听 NSWindow.didMoveNotification，将 AppKit 窗口坐标转为 Finder 桌面坐标，按图标数量动态节流并 final sync

模块法则:
App 层只处理窗口、菜单、弹窗与文案；Finder 副作用必须通过 DeskMagnetCore 的 AppCoordinator。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
