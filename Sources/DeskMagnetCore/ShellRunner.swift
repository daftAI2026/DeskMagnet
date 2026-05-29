/**
 * [INPUT]: 依赖 Foundation.Process 执行 defaults、osascript、open、pgrep 等系统命令。
 * [OUTPUT]: 对外提供 ShellRunning 协议、ShellResult 和 ProcessShellRunner。
 * [POS]: DeskMagnetCore 的系统边界层，隔离真实进程调用以便 P0Workflow 可测试。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Foundation

public struct ShellResult: Equatable, Sendable {
    public let stdout: String
    public let stderr: String
    public let exitCode: Int32

    public init(stdout: String, stderr: String, exitCode: Int32) {
        self.stdout = stdout
        self.stderr = stderr
        self.exitCode = exitCode
    }
}

public protocol ShellRunning: AnyObject, Sendable {
    func run(_ executable: String, _ arguments: [String]) async throws -> ShellResult
}

public final class ProcessShellRunner: ShellRunning, @unchecked Sendable {
    public init() {}

    public func run(_ executable: String, _ arguments: [String]) async throws -> ShellResult {
        try await Task.detached(priority: .userInitiated) {
            let process = Process()
            let output = Pipe()
            let error = Pipe()
            process.executableURL = URL(fileURLWithPath: executable)
            process.arguments = arguments
            process.standardOutput = output
            process.standardError = error
            try process.run()
            process.waitUntilExit()
            return ShellResult(
                stdout: String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "",
                stderr: String(data: error.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "",
                exitCode: process.terminationStatus
            )
        }.value
    }
}

extension ShellRunning {
    func checkedRun(_ executable: String, _ arguments: [String]) async throws -> String {
        let result = try await run(executable, arguments)
        guard result.exitCode == 0 else {
            throw DeskMagnetError.shellFailed(command: ([executable] + arguments).joined(separator: " "), stderr: result.stderr)
        }
        return result.stdout
    }
}
