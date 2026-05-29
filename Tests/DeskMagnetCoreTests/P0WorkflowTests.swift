/**
 * [INPUT]: 依赖 Foundation、Testing 与 DeskMagnetCore 的 P0Workflow/ShellRunning。
 * [OUTPUT]: 提供 P0 失败恢复路径测试与 RecordingShellRunner 替身。
 * [POS]: DeskMagnetCoreTests 的编排层测试，确保读取失败时仍恢复 Finder 设置。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Foundation
import Testing
@testable import DeskMagnetCore

@Suite("P0 workflow")
struct P0WorkflowTests {
    @Test("P0 runner restores Finder settings even when icon positions are unreadable")
    func p0RestoresFinderSettingsOnUnreadablePositions() async throws {
        let shell = RecordingShellRunner.successThenUnreadablePositions()
        let context = P0Workflow.Context(
            appSupportDirectory: URL(fileURLWithPath: "/tmp/DeskMagnetTests"),
            snapshotURL: URL(fileURLWithPath: "/tmp/DeskMagnetTests/finder-before.plist")
        )
        let workflow = P0Workflow(shell: shell, context: context)

        await #expect(throws: DeskMagnetError.self) {
            try await workflow.run()
        }

        #expect(shell.commands.contains(["/usr/bin/defaults", "import", "com.apple.finder", "/tmp/DeskMagnetTests/finder-before.plist"]))
    }

    @Test("P0 runner restores Finder settings when compatibility mode fails")
    func p0RestoresFinderSettingsOnCompatibilityFailure() async throws {
        let shell = RecordingShellRunner.compatibilityFailureAfterSnapshot()
        let context = P0Workflow.Context(
            appSupportDirectory: URL(fileURLWithPath: "/tmp/DeskMagnetTests"),
            snapshotURL: URL(fileURLWithPath: "/tmp/DeskMagnetTests/finder-before.plist")
        )
        let workflow = P0Workflow(shell: shell, context: context)

        await #expect(throws: DeskMagnetError.self) {
            try await workflow.run()
        }

        #expect(shell.commands.contains(["/usr/bin/defaults", "import", "com.apple.finder", "/tmp/DeskMagnetTests/finder-before.plist"]))
    }

    @Test("Finder settings manager retries desktop arrangement until Finder is ready")
    func settingsManagerRetriesDesktopArrangement() async throws {
        let shell = RecordingShellRunner.arrangementSucceedsAfterRetry()
        let manager = FinderSettingsManager(shell: shell)

        try await manager.enterCompatibilityMode(snapshotURL: URL(fileURLWithPath: "/tmp/DeskMagnetTests/finder-before.plist"))

        let arrangementAttempts = shell.commands.filter {
            $0.first == "/usr/bin/osascript" && $0.joined(separator: " ").contains("icon view options")
        }
        #expect(arrangementAttempts.count == 2)
    }
}

private final class RecordingShellRunner: ShellRunning, @unchecked Sendable {
    private var results: [ShellResult]
    private(set) var commands: [[String]] = []

    init(results: [ShellResult]) {
        self.results = results
    }

    func run(_ executable: String, _ arguments: [String]) async throws -> ShellResult {
        commands.append([executable] + arguments)
        return results.isEmpty ? .success() : results.removeFirst()
    }

    static func successThenUnreadablePositions() -> RecordingShellRunner {
        RecordingShellRunner(results: [
            .success(), .success(), .stopped(), .success(), .success(), .running(), .success(),
            .success("bad\t/Users/me/Desktop/bad\t-1\t-1\n"),
            .success(), .stopped(), .success(), .success(), .running()
        ])
    }

    static func compatibilityFailureAfterSnapshot() -> RecordingShellRunner {
        RecordingShellRunner(results: [
            .success(), .success(), .stopped(), .failure("defaults write failed"),
            .success(), .stopped(), .success(), .success(), .running()
        ])
    }

    static func arrangementSucceedsAfterRetry() -> RecordingShellRunner {
        RecordingShellRunner(results: [
            .success(), .success(), .stopped(), .success(), .success(), .running(),
            .failure("desktop view is not ready"), .success()
        ])
    }
}

private extension ShellResult {
    static func success(_ stdout: String = "") -> ShellResult {
        ShellResult(stdout: stdout, stderr: "", exitCode: 0)
    }

    static func failure(_ stderr: String) -> ShellResult {
        ShellResult(stdout: "", stderr: stderr, exitCode: 1)
    }

    static func running() -> ShellResult {
        ShellResult(stdout: "123\n", stderr: "", exitCode: 0)
    }

    static func stopped() -> ShellResult {
        ShellResult(stdout: "", stderr: "", exitCode: 1)
    }
}
