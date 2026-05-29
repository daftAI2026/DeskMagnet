# DeskMagnetApp/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/Sources/CLAUDE.md

成员清单
AppDelegate.swift: AppKit 生命周期，创建主窗口、接管关闭提示、启动未恢复状态检测
ContentView.swift: SwiftUI 内容区，呈现初始、清理中、完成、错误状态和主操作按钮
DeskMagnetAppMain.swift: NSApplication 入口，设置 delegate 并启动事件循环
DeskMagnetViewModel.swift: 主窗口状态模型，调用 AppCoordinator 执行吸附、恢复、跟随同步
WindowFollowController.swift: 监听 NSWindow.didMoveNotification，节流同步 Finder 图标位置并在拖动停止后 final sync

模块法则:
App 层只处理窗口、弹窗与文案；Finder 副作用必须通过 DeskMagnetCore 的 AppCoordinator。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
