/**
 * [INPUT]: 依赖 Foundation、Testing 与 DeskMagnetCore 的 RecoveryStore/RecoveryState。
 * [OUTPUT]: 提供状态文件写入、读取、清理的单元测试。
 * [POS]: DeskMagnetCoreTests 的恢复状态测试，约束 state.json 必须早于真实移动存在。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Foundation
import Testing
@testable import DeskMagnetCore

@Suite("Recovery store")
struct RecoveryStoreTests {
    @Test("Saves and loads attached recovery state")
    func savesAndLoadsAttachedState() throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("DeskMagnetRecoveryStoreTests-\(UUID().uuidString)", isDirectory: true)
        let store = RecoveryStore(directory: directory)
        let state = RecoveryState.fixture(snapshotPath: directory.appendingPathComponent("finder-before.plist").path)

        try store.save(state)
        let loaded = try #require(try store.load())

        #expect(loaded.status == .attached)
        #expect(loaded.items.first?.name == "A.txt")
        #expect(loaded.finderSnapshotPath == state.finderSnapshotPath)
        #expect(FileManager.default.fileExists(atPath: store.stateURL.path))
    }

    @Test("Clears state file after successful restore")
    func clearsStateFile() throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("DeskMagnetRecoveryStoreClearTests-\(UUID().uuidString)", isDirectory: true)
        let store = RecoveryStore(directory: directory)

        try store.save(.fixture(snapshotPath: directory.appendingPathComponent("finder-before.plist").path))
        try store.clear()

        #expect(try store.load() == nil)
        #expect(!FileManager.default.fileExists(atPath: store.stateURL.path))
    }
}

extension RecoveryState {
    static func fixture(snapshotPath: String) -> RecoveryState {
        RecoveryState(
            schemaVersion: 1,
            status: .attached,
            createdAt: Date(timeIntervalSince1970: 1_780_000_000),
            finderSnapshotPath: snapshotPath,
            items: [
                RecoveryItem(
                    name: "A.txt",
                    path: "/Users/me/Desktop/A.txt",
                    originalPosition: Point(x: 100, y: 120),
                    attachedOffset: Offset(dx: 20, dy: 244),
                    lastKnownPosition: Point(x: 220, y: 344)
                )
            ]
        )
    }

    static func fixtureWithTwoItems(snapshotPath: String) -> RecoveryState {
        RecoveryState(
            schemaVersion: 1,
            status: .attached,
            createdAt: Date(timeIntervalSince1970: 1_780_000_000),
            finderSnapshotPath: snapshotPath,
            items: [
                RecoveryItem(
                    name: "A.txt",
                    path: "/Users/me/Desktop/A.txt",
                    originalPosition: Point(x: 100, y: 120),
                    attachedOffset: Offset(dx: 20, dy: 244),
                    lastKnownPosition: Point(x: 220, y: 344)
                ),
                RecoveryItem(
                    name: "B.txt",
                    path: "/Users/me/Desktop/B.txt",
                    originalPosition: Point(x: 180, y: 120),
                    attachedOffset: Offset(dx: 108, dy: 244),
                    lastKnownPosition: Point(x: 308, y: 344)
                )
            ]
        )
    }
}
