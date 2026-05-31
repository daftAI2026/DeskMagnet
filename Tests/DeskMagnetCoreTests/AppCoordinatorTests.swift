/**
 * [INPUT]: 依赖 Foundation、Testing 与 DeskMagnetCore 的 AppCoordinator 协议边界。
 * [OUTPUT]: 提供 P1 吸附、恢复、启动未恢复检测的编排测试。
 * [POS]: DeskMagnetCoreTests 的应用编排测试，确保状态先落盘、批量移动、恢复后清理。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Foundation
import Testing
@testable import DeskMagnetCore

@Suite("App coordinator")
struct AppCoordinatorTests {
    @Test("Attach saves recovery state before moving icons")
    func attachSavesStateBeforeMove() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("DeskMagnetAppCoordinatorTests-\(UUID().uuidString)", isDirectory: true)
        let store = RecoveryStore(directory: directory)
        let settings = RecordingSettingsManager()
        let icons = RecordingIconController(stateURL: store.stateURL, items: [
            DesktopItem(name: "A.txt", path: "/Users/me/Desktop/A.txt", position: Point(x: 10, y: 20)),
            DesktopItem(name: "B.txt", path: "/Users/me/Desktop/B.txt", position: Point(x: 40, y: 20))
        ])
        let coordinator = AppCoordinator(settings: settings, icons: icons, store: store, layout: LayoutEngine())

        let state = try await coordinator.attach(windowFrame: WindowFrame(x: 100, y: 100, width: 400, height: 240))

        #expect(state.items.count == 2)
        #expect(settings.enteredSnapshotURL == store.finderSnapshotURL)
        #expect(icons.moveBatches.count == 1)
        #expect(icons.moveObservedStateFileBeforeFirstMove)
        #expect(try store.load()?.status == .attached)
    }

    @Test("Restore moves icons home, restores Finder settings, then clears state")
    func restoreClearsStateAfterFinderRestore() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("DeskMagnetRestoreTests-\(UUID().uuidString)", isDirectory: true)
        let store = RecoveryStore(directory: directory)
        try store.save(.fixture(snapshotPath: store.finderSnapshotURL.path))
        let settings = RecordingSettingsManager()
        let icons = RecordingIconController(stateURL: store.stateURL, items: [])
        let coordinator = AppCoordinator(settings: settings, icons: icons, store: store, layout: LayoutEngine())

        let result = try await coordinator.restore()

        #expect(result.restoredCount == 1)
        #expect(result.restoredItems == ["A.txt"])
        #expect(result.finderSnapshotPath == store.finderSnapshotURL.path)
        #expect(icons.moveBatches == [[IconMove(name: "A.txt", path: "/Users/me/Desktop/A.txt", position: Point(x: 100, y: 120))]])
        #expect(settings.restoredSnapshotURL == store.finderSnapshotURL)
        #expect(try store.load() == nil)
    }

    @Test("Restore skips missing icons and still clears recovered state")
    func restoreSkipsMissingItems() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("DeskMagnetRestoreSkipTests-\(UUID().uuidString)", isDirectory: true)
        let store = RecoveryStore(directory: directory)
        try store.save(.fixtureWithTwoItems(snapshotPath: store.finderSnapshotURL.path))
        let settings = RecordingSettingsManager()
        let icons = RecordingIconController(stateURL: store.stateURL, items: [], failingMoveNames: ["B.txt"])
        let coordinator = AppCoordinator(settings: settings, icons: icons, store: store, layout: LayoutEngine())

        let result = try await coordinator.restore()

        #expect(result.restoredCount == 1)
        #expect(result.skippedCount == 1)
        #expect(result.restoredItems == ["A.txt"])
        #expect(result.skippedItems == ["B.txt"])
        #expect(settings.restoredSnapshotURL == store.finderSnapshotURL)
        #expect(try store.load() == nil)
    }

    @Test("Detects unfinished recovery state on launch")
    func detectsUnfinishedStateOnLaunch() throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("DeskMagnetUnfinishedTests-\(UUID().uuidString)", isDirectory: true)
        let store = RecoveryStore(directory: directory)
        try store.save(.fixture(snapshotPath: store.finderSnapshotURL.path))
        let coordinator = AppCoordinator(
            settings: RecordingSettingsManager(),
            icons: RecordingIconController(stateURL: store.stateURL, items: []),
            store: store,
            layout: LayoutEngine()
        )

        #expect(try coordinator.unfinishedState()?.status == .attached)
    }

    @Test("Reports corrupt recovery state instead of treating it as absent")
    func reportsCorruptRecoveryState() throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("DeskMagnetCorruptStateTests-\(UUID().uuidString)", isDirectory: true)
        let store = RecoveryStore(directory: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: store.stateURL)
        let coordinator = AppCoordinator(
            settings: RecordingSettingsManager(),
            icons: RecordingIconController(stateURL: store.stateURL, items: []),
            store: store,
            layout: LayoutEngine()
        )

        guard case let .unreadable(message) = coordinator.unfinishedStateStatus() else {
            Issue.record("Expected unreadable recovery state")
            return
        }
        #expect(message.contains("state.json"))
    }
}

private final class RecordingSettingsManager: FinderSettingsManaging, @unchecked Sendable {
    var enteredSnapshotURL: URL?
    var restoredSnapshotURL: URL?

    func enterCompatibilityMode(snapshotURL: URL) async throws {
        enteredSnapshotURL = snapshotURL
    }

    func restoreFinderSettings(snapshotURL: URL) async throws {
        restoredSnapshotURL = snapshotURL
    }
}

private final class RecordingIconController: FinderIconControlling, @unchecked Sendable {
    let stateURL: URL
    let items: [DesktopItem]
    let failingMoveNames: Set<String>
    var moveBatches: [[IconMove]] = []
    var moveObservedStateFileBeforeFirstMove = false

    init(stateURL: URL, items: [DesktopItem], failingMoveNames: Set<String> = []) {
        self.stateURL = stateURL
        self.items = items
        self.failingMoveNames = failingMoveNames
    }

    func readDesktopItems() async throws -> [DesktopItem] {
        items
    }

    func moveItems(_ moves: [IconMove]) async throws {
        if moveBatches.isEmpty {
            moveObservedStateFileBeforeFirstMove = FileManager.default.fileExists(atPath: stateURL.path)
        }
        if moves.contains(where: { failingMoveNames.contains($0.name) }) {
            throw DeskMagnetError.shellFailed(command: "move", stderr: "missing item")
        }
        moveBatches.append(moves)
    }
}
