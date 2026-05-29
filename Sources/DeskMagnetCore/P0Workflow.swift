/**
 * [INPUT]: 依赖 FinderSettingsManager、FinderIconController 和本地 Application Support 路径。
 * [OUTPUT]: 对外提供 P0Workflow.run() 执行保存设置、兼容模式、读取坐标、移动一个图标、恢复的验证链。
 * [POS]: DeskMagnetCore 的 P0 编排器，是后续 AppCoordinator 的最小可证核心。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Foundation

public final class P0Workflow: Sendable {
    public struct Context: Sendable {
        public let appSupportDirectory: URL
        public let snapshotURL: URL

        public init(appSupportDirectory: URL, snapshotURL: URL) {
            self.appSupportDirectory = appSupportDirectory
            self.snapshotURL = snapshotURL
        }

        public static func live() throws -> Context {
            let base = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("DeskMagnet", isDirectory: true)
            return Context(appSupportDirectory: base, snapshotURL: base.appendingPathComponent("finder-before.plist"))
        }
    }

    private let settings: FinderSettingsManager
    private let icons: FinderIconController
    private let context: Context

    public init(shell: ShellRunning = ProcessShellRunner(), context: Context) {
        self.settings = FinderSettingsManager(shell: shell)
        self.icons = FinderIconController(shell: shell)
        self.context = context
    }

    public func run() async throws -> P0Snapshot {
        do {
            try await settings.enterCompatibilityMode(snapshotURL: context.snapshotURL)
            let items = try await icons.readDesktopItems()
            guard FinderIconController.validatePositions(items) else { throw DeskMagnetError.unreadableDesktopPositions }
            let item = try firstMovableItem(in: items)
            let moved = Point(x: item.position.x + 96, y: item.position.y)
            try await icons.moveItems([IconMove(name: item.name, position: moved)])
            try await icons.moveItems([IconMove(name: item.name, position: item.position)])
            try await settings.restoreFinderSettings(snapshotURL: context.snapshotURL)
            return P0Snapshot(item: item, movedPosition: moved, createdAt: Date())
        } catch {
            try? await settings.restoreFinderSettings(snapshotURL: context.snapshotURL)
            throw error
        }
    }

    private func firstMovableItem(in items: [DesktopItem]) throws -> DesktopItem {
        guard let item = items.first(where: { $0.position.isValidDesktopPosition }) else {
            throw DeskMagnetError.noMovableDesktopItems
        }
        return item
    }
}
