/**
 * [INPUT]: 依赖 AppKit/SwiftUI 创建 NSWindow，依赖 DeskMagnetCore.AppCoordinator 恢复未完成状态。
 * [OUTPUT]: 提供 AppDelegate，管理主窗口、关闭确认、启动恢复提示。
 * [POS]: DeskMagnetApp 的生命周期控制器，连接 macOS 窗口事件与 DeskMagnetViewModel。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import AppKit
import DeskMagnetCore
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var window: NSWindow?
    private var viewModel: DeskMagnetViewModel?
    private var followController: WindowFollowController?
    private var closingAfterRestore = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        do {
            let store = try RecoveryStore.live()
            let coordinator = AppCoordinator(store: store)
            let model = DeskMagnetViewModel(coordinator: coordinator)
            let content = ContentView(viewModel: model)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 260),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "桌面清理大师"
            window.minSize = NSSize(width: 360, height: 220)
            window.contentView = NSHostingView(rootView: content)
            window.center()
            window.delegate = self
            model.windowFrameProvider = { [weak window] in window?.deskMagnetFrame }
            self.window = window
            self.viewModel = model
            self.followController = WindowFollowController(window: window) { [weak model] frame, isFinal in
                Task { @MainActor in
                    await model?.sync(windowFrame: frame, final: isFinal)
                }
            }
            window.makeKeyAndOrderFront(nil)
            promptForUnfinishedStateIfNeeded(model: model)
        } catch {
            showFatalError(error)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard let viewModel, viewModel.isAttached, !closingAfterRestore else { return true }
        let alert = NSAlert()
        alert.messageText = "桌面图标仍处于吸附状态。"
        alert.informativeText = "是否恢复桌面后退出？"
        alert.addButton(withTitle: "恢复并退出")
        alert.addButton(withTitle: "保持现状")
        alert.addButton(withTitle: "取消")
        switch alert.runModal() {
        case .alertFirstButtonReturn:
            closingAfterRestore = true
            Task { @MainActor in
                await viewModel.restore()
                NSApplication.shared.terminate(nil)
            }
            return false
        case .alertSecondButtonReturn:
            return true
        default:
            return false
        }
    }

    private func promptForUnfinishedStateIfNeeded(model: DeskMagnetViewModel) {
        guard model.hasUnfinishedState else { return }
        let alert = NSAlert()
        alert.messageText = "检测到上次桌面未恢复"
        alert.informativeText = "是否现在恢复？"
        alert.addButton(withTitle: "立即恢复")
        alert.addButton(withTitle: "稍后")
        if alert.runModal() == .alertFirstButtonReturn {
            Task { @MainActor in await model.restore() }
        }
    }

    private func showFatalError(_ error: Error) {
        let alert = NSAlert(error: error)
        alert.messageText = "DeskMagnet 启动失败"
        alert.runModal()
        NSApplication.shared.terminate(nil)
    }
}

private extension NSWindow {
    var deskMagnetFrame: WindowFrame {
        WindowFrame(
            x: Int(frame.origin.x.rounded()),
            y: Int(frame.origin.y.rounded()),
            width: Int(frame.size.width.rounded()),
            height: Int(frame.size.height.rounded())
        )
    }
}
