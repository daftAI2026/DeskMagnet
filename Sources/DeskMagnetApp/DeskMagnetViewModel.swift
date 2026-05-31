/**
 * [INPUT]: 依赖 Foundation、SwiftUI Observation、AppLocalization 和 DeskMagnetCore.AppCoordinator。
 * [OUTPUT]: 提供 DeskMagnetViewModel，暴露窗口状态、状态损坏可见性、按钮动作、关闭恢复动作、拖动同步动作和焦点恢复回调。
 * [POS]: DeskMagnetApp 的状态模型，隔离 UI 文案与核心 Finder 编排。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import DeskMagnetCore
import Foundation

@MainActor
final class DeskMagnetViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case working(Double)
        case attached(Int)
        case restoring
        case failed(String)
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var detailNote: String?
    var windowFrameProvider: (() -> WindowFrame?)?
    var focusRestorer: (() -> Void)?

    private let coordinator: AppCoordinator
    private let languageStore: AppLanguageStore
    private var attachedIconCount = 0

    init(coordinator: AppCoordinator, languageStore: AppLanguageStore) {
        self.coordinator = coordinator
        self.languageStore = languageStore
    }

    var isAttached: Bool {
        if case .attached = phase { return true }
        if case .attached = coordinator.unfinishedStateStatus() { return true }
        return false
    }

    var hasUnfinishedState: Bool {
        switch coordinator.unfinishedStateStatus() {
        case .none:
            false
        case .attached, .unreadable:
            true
        }
    }

    var primaryButtonTitle: String {
        switch phase {
        case .idle, .failed:
            languageStore.strings.cleanButton
        case .attached:
            ""
        case .working, .restoring:
            languageStore.strings.cleaningTitle
        }
    }

    var canClean: Bool {
        switch phase {
        case .idle, .failed:
            true
        default:
            false
        }
    }

    var canRestore: Bool {
        switch phase {
        case .attached:
            true
        case .idle, .failed:
            hasUnfinishedState
        default:
            false
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
            languageStore.strings.permissionFootnote
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
            phase = .failed(languageStore.strings.windowPositionUnavailable)
            return
        }
        defer { focusRestorer?() }
        phase = .working(0.25)
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
        _ = await restoreDesktop()
    }

    func restoreForTermination() async -> Bool {
        await restoreDesktop()
    }

    private func restoreDesktop() async -> Bool {
        defer { focusRestorer?() }
        phase = .restoring
        do {
            _ = try await coordinator.restore()
            attachedIconCount = 0
            detailNote = nil
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
            return languageStore.strings.automationPermissionRequired
        }
        return String(describing: error)
    }
}
