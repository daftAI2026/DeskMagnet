/**
 * [INPUT]: 依赖 Foundation 的 URL/Date，承载 Finder 桌面项目与移动命令的纯数据。
 * [OUTPUT]: 对外提供 Point、DesktopItem、IconMove、RecoveryStateStatus、P0Snapshot、DeskMagnetError。
 * [POS]: DeskMagnetCore 的领域模型层，被 FinderIconController、P0Workflow 和 CLI 共同消费。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Foundation

public struct Point: Codable, Equatable, Sendable {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public var isValidDesktopPosition: Bool {
        x >= 0 && y >= 0
    }
}

public struct Offset: Codable, Equatable, Sendable {
    public let dx: Int
    public let dy: Int

    public init(dx: Int, dy: Int) {
        self.dx = dx
        self.dy = dy
    }
}

public struct WindowFrame: Codable, Equatable, Sendable {
    public let x: Int
    public let y: Int
    public let width: Int
    public let height: Int

    public init(x: Int, y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

public struct ScreenFrame: Codable, Equatable, Sendable {
    public let x: Int
    public let y: Int
    public let width: Int
    public let height: Int

    public init(x: Int, y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public var maxX: Int { x + width }
    public var maxY: Int { y + height }

    public func contains(x pointX: Int, y pointY: Int) -> Bool {
        pointX >= x && pointX <= maxX && pointY >= y && pointY <= maxY
    }

    public func clamped(_ point: Point, iconSize: Int = 48) -> Point {
        Point(
            x: min(max(point.x, x), maxX - iconSize),
            y: min(max(point.y, y), maxY - iconSize)
        )
    }
}

public struct DesktopItem: Codable, Equatable, Sendable {
    public let name: String
    public let path: String
    public let position: Point

    public init(name: String, path: String, position: Point) {
        self.name = name
        self.path = path
        self.position = position
    }
}

public struct IconMove: Equatable, Sendable {
    public let name: String
    public let path: String?
    public let position: Point

    public init(name: String, path: String? = nil, position: Point) {
        self.name = name
        self.path = path
        self.position = position
    }
}

public struct P0Snapshot: Codable, Equatable, Sendable {
    public let item: DesktopItem
    public let movedPosition: Point
    public let createdAt: Date
}

public enum RecoveryStatus: String, Codable, Equatable, Sendable {
    case attached
}

public struct RecoveryItem: Codable, Equatable, Sendable {
    public let name: String
    public let path: String
    public let originalPosition: Point
    public let attachedOffset: Offset
    public let lastKnownPosition: Point

    public init(
        name: String,
        path: String,
        originalPosition: Point,
        attachedOffset: Offset,
        lastKnownPosition: Point
    ) {
        self.name = name
        self.path = path
        self.originalPosition = originalPosition
        self.attachedOffset = attachedOffset
        self.lastKnownPosition = lastKnownPosition
    }
}

public struct RecoveryState: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let status: RecoveryStatus
    public let createdAt: Date
    public let finderSnapshotPath: String
    public let items: [RecoveryItem]

    public init(
        schemaVersion: Int,
        status: RecoveryStatus,
        createdAt: Date,
        finderSnapshotPath: String,
        items: [RecoveryItem]
    ) {
        self.schemaVersion = schemaVersion
        self.status = status
        self.createdAt = createdAt
        self.finderSnapshotPath = finderSnapshotPath
        self.items = items
    }
}

public struct RestoreResult: Equatable, Sendable {
    public let restoredCount: Int
    public let skippedCount: Int
    public let restoredItems: [String]
    public let skippedItems: [String]
    public let finderSnapshotPath: String

    public init(
        restoredCount: Int,
        skippedCount: Int,
        restoredItems: [String] = [],
        skippedItems: [String] = [],
        finderSnapshotPath: String = ""
    ) {
        self.restoredCount = restoredCount
        self.skippedCount = skippedCount
        self.restoredItems = restoredItems
        self.skippedItems = skippedItems
        self.finderSnapshotPath = finderSnapshotPath
    }
}

public enum RecoveryStateStatus: Equatable, Sendable {
    case none
    case attached(RecoveryState)
    case unreadable(String)
}

public enum DragSyncMode: Equatable, Sendable {
    case allDuringDrag
    case sampledDuringDrag(sampleLimit: Int)
    case finalOnly
}

public struct IconPerformanceStrategy: Equatable, Sendable {
    public let mode: DragSyncMode
    public let throttleMilliseconds: Int
    public let warning: String?

    public init(mode: DragSyncMode, throttleMilliseconds: Int, warning: String? = nil) {
        self.mode = mode
        self.throttleMilliseconds = throttleMilliseconds
        self.warning = warning
    }
}

public enum IconPerformancePolicy {
    public static func strategy(for iconCount: Int) -> IconPerformanceStrategy {
        switch iconCount {
        case 0...30:
            IconPerformanceStrategy(mode: .allDuringDrag, throttleMilliseconds: 100)
        case 31...100:
            IconPerformanceStrategy(mode: .allDuringDrag, throttleMilliseconds: 200)
        case 101...300:
            IconPerformanceStrategy(
                mode: .sampledDuringDrag(sampleLimit: 60),
                throttleMilliseconds: 250,
                warning: "桌面图标较多，拖动时将抽样跟随，松手后全量同步。"
            )
        default:
            IconPerformanceStrategy(
                mode: .finalOnly,
                throttleMilliseconds: 350,
                warning: "桌面图标超过 300 个，拖动中暂停实时跟随，松手后全量同步。"
            )
        }
    }
}

public enum DeskMagnetError: Error, Equatable, CustomStringConvertible {
    case shellFailed(command: String, stderr: String)
    case finderTimeout(String)
    case unreadableDesktopPositions
    case noMovableDesktopItems
    case malformedDesktopItemLine(String)

    public var description: String {
        switch self {
        case let .shellFailed(command, stderr):
            "Command failed: \(command)\n\(stderr)"
        case let .finderTimeout(message):
            "Finder timeout: \(message)"
        case .unreadableDesktopPositions:
            "Finder returned mostly invalid desktop positions."
        case .noMovableDesktopItems:
            "No movable desktop items were found."
        case let .malformedDesktopItemLine(line):
            "Malformed Finder item line: \(line)"
        }
    }
}
