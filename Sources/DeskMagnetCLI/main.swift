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
        let arguments = Array(CommandLine.arguments.dropFirst())
        guard arguments == ["p0", "--yes"] || arguments == ["p1", "--yes"] else {
            print("Usage: deskmagnet p0 --yes")
            print("       deskmagnet p1 --yes")
            print("P0 temporarily changes Finder desktop layout, moves one icon, then restores it.")
            print("P1 batch-attaches desktop icons, syncs a moved window frame, then restores everything.")
            return
        }

        do {
            if arguments.first == "p0" {
                try await runP0()
            } else {
                try await runP1()
            }
        } catch {
            print("DeskMagnet verification failed: \(error)")
            Foundation.exit(1)
        }
    }

    private static func runP0() async throws {
        let context = try P0Workflow.Context.live()
        let snapshot = try await P0Workflow(context: context).run()
        print("P0 passed.")
        print("Moved item: \(snapshot.item.name)")
        print("Original: \(snapshot.item.position.x), \(snapshot.item.position.y)")
        print("Temporary: \(snapshot.movedPosition.x), \(snapshot.movedPosition.y)")
        print("Finder snapshot: \(context.snapshotURL.path)")
    }

    private static func runP1() async throws {
        let store = try RecoveryStore.live()
        let coordinator = AppCoordinator(store: store)
        let initialFrame = WindowFrame(x: 320, y: 220, width: 400, height: 260)
        let movedFrame = WindowFrame(x: 420, y: 260, width: 400, height: 260)
        let state = try await coordinator.attach(windowFrame: initialFrame)
        try await coordinator.syncAttachedIcons(windowFrame: movedFrame)
        let result = try await coordinator.restore()
        print("P1 passed.")
        print("Attached items: \(state.items.count)")
        print("Restored items: \(result.restoredCount)")
        print("Finder snapshot: \(store.finderSnapshotURL.path)")
    }
}
