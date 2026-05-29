/**
 * [INPUT]: 依赖 AppKit 的 NSWindow.didMoveNotification 与 Foundation Timer。
 * [OUTPUT]: 提供 WindowFollowController，节流窗口移动同步并在停止后 final sync。
 * [POS]: DeskMagnetApp 的窗口事件适配器，被 AppDelegate 持有，向 ViewModel 输出 WindowFrame。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import AppKit
import DeskMagnetCore
import Foundation

@MainActor
final class WindowFollowController {
    private weak var window: NSWindow?
    private let onMove: (WindowFrame, Bool) -> Void
    private let throttleMilliseconds: () -> Int
    private var lastSync = Date.distantPast
    private var finalTimer: Timer?
    private var observer: NSObjectProtocol?

    init(
        window: NSWindow,
        onMove: @escaping (WindowFrame, Bool) -> Void,
        throttleMilliseconds: @escaping () -> Int
    ) {
        self.window = window
        self.onMove = onMove
        self.throttleMilliseconds = throttleMilliseconds
        self.observer = NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.windowDidMove() }
        }
    }

    func invalidate() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        finalTimer?.invalidate()
        observer = nil
        finalTimer = nil
    }

    private func windowDidMove() {
        guard let frame = window?.deskMagnetFollowFrame else { return }
        let now = Date()
        let interval = Double(throttleMilliseconds()) / 1000
        if now.timeIntervalSince(lastSync) >= interval {
            lastSync = now
            onMove(frame, false)
        }
        finalTimer?.invalidate()
        finalTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self, let frame = self.window?.deskMagnetFollowFrame else { return }
                self.onMove(frame, true)
            }
        }
    }
}

private extension NSWindow {
    var deskMagnetFollowFrame: WindowFrame {
        WindowFrame(
            x: Int(frame.origin.x.rounded()),
            y: Int(frame.origin.y.rounded()),
            width: Int(frame.size.width.rounded()),
            height: Int(frame.size.height.rounded())
        )
    }
}
