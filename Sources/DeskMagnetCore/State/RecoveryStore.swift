/**
 * [INPUT]: 依赖 Foundation 的 FileManager、JSONEncoder、JSONDecoder 管理 Application Support 状态文件。
 * [OUTPUT]: 对外提供 RecoveryStore，读写 `state.json` 和 Finder 快照路径。
 * [POS]: DeskMagnetCore 的恢复记忆层，被 AppCoordinator 在真实移动前写入、恢复成功后清理。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Foundation

public struct RecoveryStore: Sendable {
    public let directory: URL
    public let stateURL: URL
    public let finderSnapshotURL: URL

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(directory: URL) {
        self.directory = directory
        self.stateURL = directory.appendingPathComponent("state.json")
        self.finderSnapshotURL = directory.appendingPathComponent("finder-before.plist")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public static func live() throws -> RecoveryStore {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("DeskMagnet", isDirectory: true)
        return RecoveryStore(directory: base)
    }

    public func save(_ state: RecoveryState) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try encoder.encode(state)
        try data.write(to: stateURL, options: [.atomic])
    }

    public func load() throws -> RecoveryState? {
        guard FileManager.default.fileExists(atPath: stateURL.path) else { return nil }
        let data = try Data(contentsOf: stateURL)
        return try decoder.decode(RecoveryState.self, from: data)
    }

    public func clear() throws {
        guard FileManager.default.fileExists(atPath: stateURL.path) else { return }
        try FileManager.default.removeItem(at: stateURL)
    }
}
