/**
 * [INPUT]: 依赖 FinderSettingsManaging、FinderIconControlling、RecoveryStore、LayoutEngine 串联真实桌面吸附流程。
 * [OUTPUT]: 对外提供 AppCoordinator.attach、restore、syncAttachedIcons、unfinishedState。
 * [POS]: DeskMagnetCore 的 P1 应用编排层，被 SwiftUI/AppKit 外壳调用。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Foundation

public protocol FinderSettingsManaging: Sendable {
    func enterCompatibilityMode(snapshotURL: URL) async throws
    func restoreFinderSettings(snapshotURL: URL) async throws
}

public protocol FinderIconControlling: Sendable {
    func readDesktopItems() async throws -> [DesktopItem]
    func moveItems(_ moves: [IconMove]) async throws
}

extension FinderSettingsManager: FinderSettingsManaging {}
extension FinderIconController: FinderIconControlling {}

public final class AppCoordinator: Sendable {
    private let settings: FinderSettingsManaging
    private let icons: FinderIconControlling
    private let store: RecoveryStore
    private let layout: LayoutEngine

    public init(
        settings: FinderSettingsManaging = FinderSettingsManager(),
        icons: FinderIconControlling = FinderIconController(),
        store: RecoveryStore,
        layout: LayoutEngine = LayoutEngine()
    ) {
        self.settings = settings
        self.icons = icons
        self.store = store
        self.layout = layout
    }

    public func unfinishedState() throws -> RecoveryState? {
        try store.load()
    }

    public func attach(windowFrame: WindowFrame) async throws -> RecoveryState {
        do {
            try await settings.enterCompatibilityMode(snapshotURL: store.finderSnapshotURL)
            let desktopItems = try await icons.readDesktopItems()
            guard FinderIconController.validatePositions(desktopItems) else {
                throw DeskMagnetError.unreadableDesktopPositions
            }
            let recoveryItems = layout.attach(
                items: desktopItems.filter { $0.position.isValidDesktopPosition },
                to: windowFrame
            )
            guard !recoveryItems.isEmpty else { throw DeskMagnetError.noMovableDesktopItems }
            let state = RecoveryState(
                schemaVersion: 1,
                status: .attached,
                createdAt: Date(),
                finderSnapshotPath: store.finderSnapshotURL.path,
                items: recoveryItems
            )
            try store.save(state)
            try await icons.moveItems(layout.moves(for: state, windowFrame: windowFrame))
            return state
        } catch {
            try? await settings.restoreFinderSettings(snapshotURL: store.finderSnapshotURL)
            throw error
        }
    }

    public func syncAttachedIcons(windowFrame: WindowFrame) async throws {
        try await syncAttachedIcons(windowFrame: windowFrame, isFinal: true)
    }

    public func syncAttachedIcons(windowFrame: WindowFrame, isFinal: Bool) async throws {
        guard let state = try store.load() else { return }
        let strategy = IconPerformancePolicy.strategy(for: state.items.count)
        guard isFinal || strategy.mode != .finalOnly else { return }
        let moves = sampledMoves(layout.moves(for: state, windowFrame: windowFrame), strategy: strategy, isFinal: isFinal)
        try await icons.moveItems(moves)
    }

    public func restore() async throws -> RestoreResult {
        guard let state = try store.load() else {
            return RestoreResult(restoredCount: 0, skippedCount: 0)
        }

        var moveError: Error?
        do {
            try await icons.moveItems(layout.restoreMoves(for: state))
        } catch {
            moveError = error
        }

        try await settings.restoreFinderSettings(snapshotURL: URL(fileURLWithPath: state.finderSnapshotPath))
        if let moveError { throw moveError }

        try store.clear()
        return RestoreResult(
            restoredCount: state.items.count,
            skippedCount: 0,
            restoredItems: state.items.map(\.name),
            skippedItems: [],
            finderSnapshotPath: state.finderSnapshotPath
        )
    }

    private func sampledMoves(_ moves: [IconMove], strategy: IconPerformanceStrategy, isFinal: Bool) -> [IconMove] {
        guard !isFinal else { return moves }
        if case let .sampledDuringDrag(limit) = strategy.mode, moves.count > limit {
            return Array(moves.prefix(limit))
        }
        return moves
    }
}
