/**
 * [INPUT]: 依赖 AppKit 的 NSApplication 和 AppDelegate。
 * [OUTPUT]: 提供 DeskMagnetApp 可执行入口。
 * [POS]: DeskMagnetApp 的进程入口，只负责启动 macOS 事件循环。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import AppKit

@main
enum DeskMagnetAppMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.regular)
        app.activate(ignoringOtherApps: true)
        app.run()
    }
}
