/**
 * [INPUT]: 依赖 Testing 与 DeskMagnetCore 的脚本生成、移动模型、坐标校验能力。
 * [OUTPUT]: 提供 Finder 图标控制相关单元测试。
 * [POS]: DeskMagnetCoreTests 的脚本与校验测试，约束 FinderIconScript 和 FinderIconController 的纯逻辑。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Testing
@testable import DeskMagnetCore

@Suite("Finder icon control")
struct FinderIconControllerTests {
    @Test("AppleScript string escaping preserves quotes and backslashes")
    func appleScriptStringEscaping() {
        #expect(AppleScriptEscaper.stringLiteral("A \"quoted\" \\ icon") == "\"A \\\"quoted\\\" \\\\ icon\"")
    }

    @Test("Move script batches every icon move in one Finder block")
    func batchedMoveScript() {
        let moves = [
            IconMove(name: "A.txt", position: Point(x: 500, y: 300)),
            IconMove(name: "B \"file\".txt", position: Point(x: 588, y: 300))
        ]

        let script = FinderIconScript.moveItems(moves)

        #expect(script.contains("tell application \"Finder\""))
        #expect(script.contains("set desktop position of item \"A.txt\" of desktop to {500, 300}"))
        #expect(script.contains("set desktop position of item \"B \\\"file\\\".txt\" of desktop to {588, 300}"))
        #expect(script.filter(\.isNewline).count >= 3)
    }

    @Test("Read script uses Finder index iteration instead of broken item list references")
    func readScriptUsesIndexIteration() {
        let script = FinderIconScript.readDesktopItems()

        #expect(script.contains("repeat with i from 1 to count every item of desktop"))
        #expect(script.contains("set anItem to item i of desktop"))
        #expect(!script.contains("repeat with anItem in every item of desktop"))
    }

    @Test("Position validation requires a real majority")
    func validatesMajorityOfPositions() {
        let valid = DesktopItem(name: "ok", path: "/Users/me/Desktop/ok", position: Point(x: 10, y: 20))
        let invalid = DesktopItem(name: "bad", path: "/Users/me/Desktop/bad", position: Point(x: -1, y: -1))

        #expect(FinderIconController.validatePositions([valid, valid, invalid]))
        #expect(!FinderIconController.validatePositions([valid, invalid, invalid]))
        #expect(!FinderIconController.validatePositions([]))
    }
}
