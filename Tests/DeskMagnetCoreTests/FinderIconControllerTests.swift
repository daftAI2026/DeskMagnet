/**
 * [INPUT]: 依赖 Testing 与 DeskMagnetCore 的脚本生成、移动模型、坐标校验能力。
 * [OUTPUT]: 提供 Finder 图标控制相关单元测试。
 * [POS]: DeskMagnetCoreTests 的脚本与校验测试，约束 FinderIconScript 和 FinderIconController 的纯逻辑。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Foundation
import Testing
@testable import DeskMagnetCore

@Suite("Finder icon control")
struct FinderIconControllerTests {
    @Test("Reads JSON lines so Finder names may contain tabs and newlines")
    func readsEscapedFinderItems() async throws {
        let shell = StubShellRunner(stdout: #"{"name":"A\tquoted\nfile.txt","path":"/Users/me/Desktop/A\tquoted\nfile.txt","x":10,"y":20}"# + "\n")
        let controller = FinderIconController(shell: shell)

        let items = try await controller.readDesktopItems()

        #expect(items == [
            DesktopItem(
                name: "A\tquoted\nfile.txt",
                path: "/Users/me/Desktop/A\tquoted\nfile.txt",
                position: Point(x: 10, y: 20)
            )
        ])
    }

    @Test("AppleScript string escaping preserves quotes and backslashes")
    func appleScriptStringEscaping() {
        #expect(AppleScriptEscaper.stringLiteral("A \"quoted\" \\ icon") == "\"A \\\"quoted\\\" \\\\ icon\"")
    }

    @Test("Move script uses POSIX paths instead of display names")
    func moveScriptUsesPaths() {
        let moves = [
            IconMove(name: "A.txt", path: "/Users/me/Desktop/A.txt", position: Point(x: 500, y: 300)),
            IconMove(name: "B.txt", path: "/Users/me/Desktop/B \"file\".txt", position: Point(x: 588, y: 300))
        ]

        let script = FinderIconScript.moveItems(moves)

        #expect(script.contains("tell application \"Finder\""))
        #expect(script.contains("set targetItem to POSIX file \"/Users/me/Desktop/A.txt\" as alias"))
        #expect(script.contains("set desktop position of targetItem to {500, 300}"))
        #expect(script.contains("set targetItem to POSIX file \"/Users/me/Desktop/B \\\"file\\\".txt\" as alias"))
        #expect(!script.contains("item \"A.txt\" of desktop"))
        #expect(script.filter(\.isNewline).count >= 3)
    }

    @Test("Read script returns JSON lines with escaped strings")
    func readScriptReturnsJSONLines() {
        let script = FinderIconScript.readDesktopItems()

        #expect(script.contains("repeat with i from 1 to count every item of desktop"))
        #expect(script.contains("on jsonString(rawText)"))
        #expect(script.contains("\\\"name\\\":"))
        #expect(script.contains("\\\"path\\\":"))
        #expect(!script.contains("repeat with anItem in every item of desktop"))
    }

    @Test("Generated AppleScripts compile without executing Finder")
    func generatedScriptsCompile() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("DeskMagnetAppleScriptCompileTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let scripts = [
            "read": FinderIconScript.readDesktopItems(),
            "move": FinderIconScript.moveItems([
                IconMove(name: "A.txt", path: "/Users/me/Desktop/A.txt", position: Point(x: 10, y: 20))
            ])
        ]
        let runner = ProcessShellRunner()

        for (name, script) in scripts {
            let sourceURL = directory.appendingPathComponent("\(name).applescript")
            let outputURL = directory.appendingPathComponent("\(name).scpt")
            try script.write(to: sourceURL, atomically: true, encoding: .utf8)
            let result = try await runner.run("/usr/bin/osacompile", ["-o", outputURL.path, sourceURL.path])

            #expect(result.exitCode == 0)
            #expect(result.stderr.isEmpty)
        }
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

private final class StubShellRunner: ShellRunning, @unchecked Sendable {
    let stdout: String

    init(stdout: String) {
        self.stdout = stdout
    }

    func run(_ executable: String, _ arguments: [String]) async throws -> ShellResult {
        ShellResult(stdout: stdout, stderr: "", exitCode: 0)
    }
}
