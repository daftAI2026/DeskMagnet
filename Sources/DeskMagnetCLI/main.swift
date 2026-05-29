/**
 * [INPUT]: 依赖 DeskMagnetCore 的 P0Workflow 执行真实 Finder 桌面验证。
 * [OUTPUT]: 提供 deskmagnet p0 --yes 命令行入口，打印每次验证移动的项目与快照路径。
 * [POS]: DeskMagnetCLI 的进程入口，当前只承载 P0 技术验证器。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import DeskMagnetCore
import Foundation

@main
struct DeskMagnetCommand {
    static func main() async {
        guard CommandLine.arguments.dropFirst() == ["p0", "--yes"] else {
            print("Usage: deskmagnet p0 --yes")
            print("This temporarily changes Finder desktop layout, moves one icon, then restores it.")
            return
        }

        do {
            let context = try P0Workflow.Context.live()
            let snapshot = try await P0Workflow(context: context).run()
            print("P0 passed.")
            print("Moved item: \(snapshot.item.name)")
            print("Original: \(snapshot.item.position.x), \(snapshot.item.position.y)")
            print("Temporary: \(snapshot.movedPosition.x), \(snapshot.movedPosition.y)")
            print("Finder snapshot: \(context.snapshotURL.path)")
        } catch {
            print("P0 failed: \(error)")
            Foundation.exit(1)
        }
    }
}
