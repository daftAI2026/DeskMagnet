/**
 * [INPUT]: 依赖 Testing 与 DeskMagnetCore 的 LayoutEngine、DesktopItem、WindowFrame。
 * [OUTPUT]: 提供窗口安全投影内吸附、宽窗口扩列、屏幕边界裁剪与窗口同步移动测试。
 * [POS]: DeskMagnetCoreTests 的布局测试，约束图标落在窗口内部安全区，由桌面层承担 Z 轴遮盖。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Testing
@testable import DeskMagnetCore

@Suite("Layout engine")
struct LayoutEngineTests {
    @Test("Generates stable hidden projection offsets")
    func generatesStableHiddenProjectionOffsets() {
        let items = (0..<5).map {
            DesktopItem(name: "\($0).txt", path: "/tmp/\($0).txt", position: Point(x: 10, y: 10))
        }
        let frame = WindowFrame(x: 200, y: 100, width: 800, height: 520)

        let recoveryItems = LayoutEngine(jitter: .none).attach(items: items, to: frame)

        #expect(recoveryItems.count == 5)
        #expect(recoveryItems[0].attachedOffset == Offset(dx: 144, dy: 112))
        #expect(recoveryItems[0].lastKnownPosition == Point(x: 344, y: 212))
        #expect(recoveryItems.allSatisfy { $0.attachedOffset.dx >= 144 && $0.attachedOffset.dx <= 608 })
        #expect(recoveryItems.allSatisfy { $0.attachedOffset.dy >= 112 && $0.attachedOffset.dy <= 376 })
    }

    @Test("Uses window width before stacking icons downward")
    func usesWindowWidthBeforeStackingDownward() {
        let items = (0..<26).map {
            DesktopItem(name: "\($0).txt", path: "/tmp/\($0).txt", position: Point(x: 10, y: 10))
        }
        let frame = WindowFrame(x: 100, y: 80, width: 1_280, height: 520)

        let recoveryItems = LayoutEngine(jitter: .none).attach(items: items, to: frame)
        let rowOffsets = Set(recoveryItems.map(\.attachedOffset.dy))

        #expect(rowOffsets.count == 3)
        #expect(recoveryItems.last?.lastKnownPosition.y == 368)
    }

    @Test("Keeps icons under the window when below area is unavailable")
    func keepsIconsUnderWindowWhenBelowAreaUnavailable() {
        let items = [DesktopItem(name: "A.txt", path: "/tmp/A.txt", position: Point(x: 10, y: 10))]
        let frame = WindowFrame(x: 100, y: 80, width: 800, height: 520)
        let engine = LayoutEngine(jitter: .none, screens: [
            ScreenFrame(x: 0, y: 0, width: 1_200, height: 640)
        ])

        let recoveryItems = engine.attach(items: items, to: frame)

        #expect(recoveryItems.first?.lastKnownPosition == Point(x: 244, y: 192))
    }

    @Test("Keeps first row inside the window projection when one row fits")
    func keepsFirstRowInsideWindowProjectionWhenOneRowFits() {
        let items = [DesktopItem(name: "A.txt", path: "/tmp/A.txt", position: Point(x: 10, y: 10))]
        let frame = WindowFrame(x: 100, y: 80, width: 800, height: 520)
        let engine = LayoutEngine(jitter: .none, screens: [
            ScreenFrame(x: 0, y: 0, width: 1_200, height: 680)
        ])

        let recoveryItems = engine.attach(items: items, to: frame)

        #expect(recoveryItems.first?.lastKnownPosition == Point(x: 244, y: 192))
    }

    @Test("Recomputes moves inside the window projection")
    func recomputesMovesInsideWindowProjection() {
        let state = RecoveryState.fixture(snapshotPath: "/tmp/finder.plist")
        let engine = LayoutEngine(jitter: .none, screens: [
            ScreenFrame(x: 0, y: 0, width: 1_200, height: 640)
        ])

        let moves = engine.moves(for: state, windowFrame: WindowFrame(x: 100, y: 80, width: 800, height: 520))

        #expect(moves == [IconMove(name: "A.txt", path: "/Users/me/Desktop/A.txt", position: Point(x: 244, y: 192))])
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
        #expect(first.contains { $0.attachedOffset.dx != 144 })
        #expect(first.allSatisfy { $0.lastKnownPosition.x >= 1_044 && $0.lastKnownPosition.x <= 1_212 })
        #expect(first.allSatisfy { $0.lastKnownPosition.y >= 232 && $0.lastKnownPosition.y <= 292 })
    }
}
