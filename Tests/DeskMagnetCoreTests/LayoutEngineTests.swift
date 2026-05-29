/**
 * [INPUT]: 依赖 Testing 与 DeskMagnetCore 的 LayoutEngine、DesktopItem、WindowFrame。
 * [OUTPUT]: 提供吸附布局与窗口同步移动测试。
 * [POS]: DeskMagnetCoreTests 的布局测试，约束图标落在窗口下方且偏移稳定复用。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Testing
@testable import DeskMagnetCore

@Suite("Layout engine")
struct LayoutEngineTests {
    @Test("Generates stable below-window offsets")
    func generatesBelowWindowOffsets() {
        let items = (0..<5).map {
            DesktopItem(name: "\($0).txt", path: "/tmp/\($0).txt", position: Point(x: 10, y: 10))
        }
        let frame = WindowFrame(x: 200, y: 100, width: 400, height: 240)

        let recoveryItems = LayoutEngine(jitter: .none).attach(items: items, to: frame)

        #expect(recoveryItems.count == 5)
        #expect(recoveryItems[0].attachedOffset == Offset(dx: 20, dy: 264))
        #expect(recoveryItems[0].lastKnownPosition == Point(x: 220, y: 364))
        #expect(recoveryItems[4].attachedOffset.dy > recoveryItems[0].attachedOffset.dy)
    }

    @Test("Computes moves from stored offsets without changing originals")
    func computesMovesFromStoredOffsets() {
        let state = RecoveryState.fixture(snapshotPath: "/tmp/finder.plist")
        let moves = LayoutEngine().moves(for: state, windowFrame: WindowFrame(x: 300, y: 200, width: 400, height: 240))

        #expect(moves == [IconMove(name: "A.txt", position: Point(x: 320, y: 444))])
    }

    @Test("Applies deterministic jitter without moving icons outside the active screen")
    func appliesJitterInsideActiveScreen() {
        let items = (0..<12).map {
            DesktopItem(name: "\($0).txt", path: "/tmp/\($0).txt", position: Point(x: 10, y: 10))
        }
        let engine = LayoutEngine(jitter: .deterministic, screens: [
            ScreenFrame(x: 0, y: 0, width: 800, height: 600),
            ScreenFrame(x: 800, y: 0, width: 800, height: 600)
        ])

        let first = engine.attach(items: items, to: WindowFrame(x: 900, y: 120, width: 360, height: 220))
        let second = engine.attach(items: items, to: WindowFrame(x: 900, y: 120, width: 360, height: 220))

        #expect(first == second)
        #expect(first.contains { $0.attachedOffset.dx != 20 })
        #expect(first.allSatisfy { $0.lastKnownPosition.x >= 800 && $0.lastKnownPosition.x <= 1552 })
        #expect(first.allSatisfy { $0.lastKnownPosition.y >= 0 && $0.lastKnownPosition.y <= 552 })
    }
}
