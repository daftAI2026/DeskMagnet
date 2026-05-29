/**
 * [INPUT]: 依赖 ShellRunning 执行 defaults、osascript、open、pgrep，依赖轮询等待 Finder 状态。
 * [OUTPUT]: 对外提供 FinderSettingsManager.snapshotFinderSettings()、enterCompatibilityMode(snapshotURL:)、restoreFinderSettings(snapshotURL:)。
 * [POS]: DeskMagnetCore 的 Finder 偏好生命周期管理器，保证修改前快照、失败后可恢复。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Foundation

public final class FinderSettingsManager: Sendable {
    private let shell: ShellRunning

    public init(shell: ShellRunning = ProcessShellRunner()) {
        self.shell = shell
    }

    public func snapshotFinderSettings(to snapshotURL: URL) async throws {
        try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        _ = try await shell.checkedRun("/usr/bin/defaults", ["export", "com.apple.finder", snapshotURL.path])
    }

    public func enterCompatibilityMode(snapshotURL: URL) async throws {
        try await snapshotFinderSettings(to: snapshotURL)
        try await quitFinderAndWait()
        _ = try await shell.checkedRun("/usr/bin/defaults", ["write", "com.apple.finder", "DesktopViewSettings", "-dict", "GroupBy", "None"])
        try await openFinderAndWait()
        try await setDesktopArrangementNotArranged()
    }

    public func restoreFinderSettings(snapshotURL: URL) async throws {
        try await quitFinderAndWait()
        _ = try await shell.checkedRun("/usr/bin/defaults", ["import", "com.apple.finder", snapshotURL.path])
        try await openFinderAndWait()
    }

    private func quitFinderAndWait() async throws {
        _ = try await shell.checkedRun("/usr/bin/osascript", ["-e", FinderIconScript.quitFinder()])
        try await waitForFinder(running: false, timeout: 10)
    }

    private func openFinderAndWait() async throws {
        _ = try await shell.checkedRun("/usr/bin/open", ["-a", "Finder"])
        try await waitForFinder(running: true, timeout: 10)
    }

    private func setDesktopArrangementNotArranged() async throws {
        let script = FinderIconScript.setDesktopArrangementNotArranged()
        let deadline = Date().addingTimeInterval(10)
        var lastError = ""
        while Date() < deadline {
            let result = try await shell.run("/usr/bin/osascript", ["-e", script])
            if result.exitCode == 0 { return }
            lastError = result.stderr
            try await Task.sleep(for: .milliseconds(250))
        }
        throw DeskMagnetError.shellFailed(command: "/usr/bin/osascript -e \(script)", stderr: lastError)
    }

    private func waitForFinder(running expected: Bool, timeout: TimeInterval) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            let result = try await shell.run("/usr/bin/pgrep", ["-x", "Finder"])
            if (result.exitCode == 0) == expected { return }
            try await Task.sleep(for: .milliseconds(250))
        }
        throw DeskMagnetError.finderTimeout(expected ? "Finder did not start." : "Finder did not quit.")
    }
}
