/**
 * [INPUT]: 依赖 Foundation、SwiftUI Observation 和 DeskMagnetCore.AppCoordinator。
 * [OUTPUT]: 提供 DeskMagnetViewModel，暴露窗口状态、按钮动作、关闭恢复动作、拖动同步动作。
 * [POS]: DeskMagnetApp 的状态模型，隔离 UI 文案与核心 Finder 编排。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import DeskMagnetCore
import Foundation

@MainActor
final class DeskMagnetViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case working(String, Double)
        case attached(Int)
        case restoring
        case failed(String)
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var detailNote: String?
    var windowFrameProvider: (() -> WindowFrame?)?

    private let coordinator: AppCoordinator
    private var attachedIconCount = 0

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    var isAttached: Bool {
        if case .attached = phase { return true }
        return (try? coordinator.unfinishedState()) != nil
    }

    var hasUnfinishedState: Bool {
        (try? coordinator.unfinishedState()) != nil
    }

    var primaryButtonTitle: String {
        switch phase {
        case .idle, .failed:
            "清理桌面"
        case .attached:
            ""
        case .working, .restoring:
            "处理中..."
        }
    }

    var showsPrimaryButton: Bool {
        switch phase {
        case .attached, .working, .restoring:
            false
        default:
            true
        }
    }

    var footnote: String {
        if let detailNote { return detailNote }
        return switch phase {
        case .idle:
            ""
        case .working:
            ""
        case .attached:
            ""
        case .restoring:
            ""
        case .failed:
            "需要允许 DeskMagnet 控制 Finder"
        }
    }

    var followThrottleMilliseconds: Int {
        IconPerformancePolicy.strategy(for: attachedIconCount).throttleMilliseconds
    }

    func primaryAction() {
        switch phase {
        case .attached:
            return
        case .working, .restoring:
            return
        case .idle, .failed:
            Task { await attach() }
        }
    }

    func attach() async {
        guard let frame = windowFrameProvider?() else {
            phase = .failed("无法读取主窗口位置。")
            return
        }
        phase = .working("正在清理桌面...", 0.25)
        do {
            let state = try await coordinator.attach(windowFrame: frame)
            attachedIconCount = state.items.count
            detailNote = IconPerformancePolicy.strategy(for: state.items.count).warning
            phase = .attached(state.items.count)
        } catch {
            detailNote = nil
            phase = .failed(userMessage(for: error))
        }
    }

    func restore() async {
        _ = await restoreDesktop(updateDetail: true)
    }

    func restoreForTermination() async -> Bool {
        await restoreDesktop(updateDetail: false)
    }

    private func restoreDesktop(updateDetail: Bool) async -> Bool {
        phase = .restoring
        do {
            let result = try await coordinator.restore()
            attachedIconCount = 0
            if updateDetail {
                detailNote = "已恢复 \(result.restoredCount) 个图标。快照：\(result.finderSnapshotPath)"
            } else {
                detailNote = nil
            }
            phase = .idle
            return true
        } catch {
            detailNote = nil
            phase = .failed(userMessage(for: error))
            return false
        }
    }

    func sync(windowFrame: WindowFrame, final: Bool) async {
        guard isAttached else { return }
        do {
            try await coordinator.syncAttachedIcons(windowFrame: windowFrame, isFinal: final)
        } catch where !final {
            return
        } catch {
            phase = .failed(userMessage(for: error))
        }
    }

    private func userMessage(for error: Error) -> String {
        if String(describing: error).contains("-1743") {
            return "需要允许 DeskMagnet 控制 Finder。请前往：系统设置 -> 隐私与安全性 -> 自动化。"
        }
        return String(describing: error)
    }
}
