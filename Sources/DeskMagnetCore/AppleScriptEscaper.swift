/**
 * [INPUT]: 依赖 Swift String 处理 Finder item 名称中的引号与反斜杠。
 * [OUTPUT]: 对外提供 AppleScriptEscaper.stringLiteral(_:)。
 * [POS]: DeskMagnetCore 的脚本文本安全层，被 FinderIconScript 复用。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

public enum AppleScriptEscaper {
    public static func stringLiteral(_ value: String) -> String {
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return "\"\(escaped)\""
    }
}
