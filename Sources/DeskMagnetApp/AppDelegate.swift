/**
 * [INPUT]: 依赖 AppKit/SwiftUI 创建 NSWindow，依赖 DeskMagnetCore.AppCoordinator 恢复未完成状态。
 * [OUTPUT]: 提供 AppDelegate，管理固定尺寸亮色主窗口、启动居中、关闭自动恢复、启动恢复提示。
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
        NSApplication.shared.appearance = NSAppearance(named: .aqua)
        do {
            let store = try RecoveryStore.live()
            let converter = NSScreen.deskMagnetCoordinateConverter
            let coordinator = AppCoordinator(store: store, layout: LayoutEngine(screens: NSScreen.deskMagnetScreens(converter: converter)))
            let model = DeskMagnetViewModel(coordinator: coordinator)
            let content = ContentView(viewModel: model)
            let windowSize = NSSize(width: 800, height: 520)
            let window = NSWindow(
                contentRect: NSRect(origin: .zero, size: windowSize),
                styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.title = "桌面清理大师"
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.minSize = windowSize
            window.maxSize = windowSize
            window.isRestorable = false
            window.appearance = NSAppearance(named: .aqua)
            window.backgroundColor = .controlBackgroundColor
            window.contentView = NSHostingView(rootView: content)
            window.deskMagnetCenterOnMainScreen()
            window.delegate = self
            model.windowFrameProvider = { [weak window] in window?.deskMagnetFrame(converter: converter) }
            self.window = window
            self.viewModel = model
            self.followController = WindowFollowController(window: window, converter: converter) { [weak model] frame, isFinal in
                Task { @MainActor in
                    await model?.sync(windowFrame: frame, final: isFinal)
                }
            } throttleMilliseconds: { [weak model] in
                model?.followThrottleMilliseconds ?? 120
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

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let viewModel, viewModel.isAttached else { return .terminateNow }
        guard !closingAfterRestore else { return .terminateLater }
        closingAfterRestore = true
        Task { @MainActor in
            let restored = await viewModel.restoreForTermination()
            closingAfterRestore = false
            sender.reply(toApplicationShouldTerminate: restored)
        }
        return .terminateLater
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard let viewModel, viewModel.isAttached else { return true }
        guard !closingAfterRestore else { return false }
        closingAfterRestore = true
        Task { @MainActor in
            let restored = await viewModel.restoreForTermination()
            closingAfterRestore = false
            if restored {
                NSApplication.shared.terminate(nil)
            }
        }
        return false
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
    func deskMagnetCenterOnMainScreen() {
        let visibleFrame = NSScreen.main?.visibleFrame ?? NSScreen.screens.first?.visibleFrame ?? frame
        setFrameOrigin(
            NSPoint(
                x: visibleFrame.midX - frame.width / 2,
                y: visibleFrame.midY - frame.height / 2
            )
        )
    }

    func deskMagnetFrame(converter: DesktopCoordinateConverter) -> WindowFrame {
        converter.windowFrameFromAppKit(
            x: Int(frame.origin.x.rounded()),
            y: Int(frame.origin.y.rounded()),
            width: Int(frame.size.width.rounded()),
            height: Int(frame.size.height.rounded())
        )
    }
}

private extension NSScreen {
    static var deskMagnetCoordinateConverter: DesktopCoordinateConverter {
        DesktopCoordinateConverter(globalMaxY: Int(screens.map(\.frame.maxY).max()?.rounded() ?? 0))
    }

    static func deskMagnetScreens(converter: DesktopCoordinateConverter) -> [ScreenFrame] {
        screens.map {
            converter.screenFrameFromAppKit(
                x: Int($0.frame.origin.x.rounded()),
                y: Int($0.frame.origin.y.rounded()),
                width: Int($0.frame.size.width.rounded()),
                height: Int($0.frame.size.height.rounded())
            )
        }
    }
}
