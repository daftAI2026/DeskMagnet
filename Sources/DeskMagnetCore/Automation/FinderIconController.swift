/**
 * [INPUT]: 依赖 ShellRunning 执行 osascript，依赖 FinderIconScript 生成 JSON 读取与路径移动脚本。
 * [OUTPUT]: 对外提供 FinderIconController.readDesktopItems()、moveItems(_:)、validatePositions(_:)。
 * [POS]: DeskMagnetCore 的桌面图标控制器，负责 Finder item 坐标 I/O 与可移动性判断。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Foundation

public final class FinderIconController: Sendable {
    private let shell: ShellRunning

    private struct FinderItemLine: Decodable {
        let name: String
        let path: String
        let x: Int
        let y: Int
    }

    public init(shell: ShellRunning = ProcessShellRunner()) {
        self.shell = shell
    }

    public func readDesktopItems() async throws -> [DesktopItem] {
        let output = try await shell.checkedRun("/usr/bin/osascript", ["-e", FinderIconScript.readDesktopItems()])
        return try output.split(separator: "\n", omittingEmptySubsequences: true).map(parseItemLine)
    }

    public func moveItems(_ moves: [IconMove]) async throws {
        guard !moves.isEmpty else { return }
        _ = try await shell.checkedRun("/usr/bin/osascript", ["-e", FinderIconScript.moveItems(moves)])
    }

    public static func validatePositions(_ items: [DesktopItem]) -> Bool {
        guard !items.isEmpty else { return false }
        let validCount = items.filter(\.position.isValidDesktopPosition).count
        return validCount * 2 > items.count
    }

    private func parseItemLine(_ line: Substring) throws -> DesktopItem {
        guard let data = String(line).data(using: .utf8),
              let item = try? JSONDecoder().decode(FinderItemLine.self, from: data)
        else {
            throw DeskMagnetError.malformedDesktopItemLine(String(line))
        }
        return DesktopItem(name: item.name, path: item.path, position: Point(x: item.x, y: item.y))
    }
}
