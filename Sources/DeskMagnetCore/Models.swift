/**
 * [INPUT]: 依赖 Foundation 的 URL/Date，承载 Finder 桌面项目与移动命令的纯数据。
 * [OUTPUT]: 对外提供 Point、DesktopItem、IconMove、P0Snapshot、DeskMagnetError。
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
    public let position: Point

    public init(name: String, position: Point) {
        self.name = name
        self.position = position
    }
}

public struct P0Snapshot: Codable, Equatable, Sendable {
    public let item: DesktopItem
    public let movedPosition: Point
    public let createdAt: Date
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
