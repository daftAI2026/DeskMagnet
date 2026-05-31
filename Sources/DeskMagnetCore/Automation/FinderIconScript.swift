/**
 * [INPUT]: 依赖 AppleScriptEscaper 与 IconMove 生成 Finder AppleScript。
 * [OUTPUT]: 对外提供 FinderIconScript.readDesktopItems() JSON line 脚本和 moveItems(_:) 路径移动脚本。
 * [POS]: DeskMagnetCore 的 Finder 脚本构造层，不执行命令，只产生命令文本并避免显示名身份歧义。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

public enum FinderIconScript {
    public static func readDesktopItems() -> String {
        """
        on replaceText(sourceText, searchText, replacementText)
            set AppleScript's text item delimiters to searchText
            set chunks to text items of sourceText
            set AppleScript's text item delimiters to replacementText
            set replacedText to chunks as text
            set AppleScript's text item delimiters to ""
            return replacedText
        end replaceText

        on jsonString(rawText)
            set escapedText to rawText as text
            set escapedText to my replaceText(escapedText, "\\\\", "\\\\\\\\")
            set escapedText to my replaceText(escapedText, "\\"", "\\\\\\"")
            set escapedText to my replaceText(escapedText, tab, "\\\\t")
            set escapedText to my replaceText(escapedText, linefeed, "\\\\n")
            set escapedText to my replaceText(escapedText, return, "\\\\r")
            return "\\"" & escapedText & "\\""
        end jsonString

        tell application "Finder"
            set out to ""
            repeat with i from 1 to count every item of desktop
                set anItem to item i of desktop
                set p to desktop position of anItem
                set itemName to name of anItem as text
                set itemPath to POSIX path of (anItem as alias)
                set out to out & "{\\"name\\":" & my jsonString(itemName) & ",\\"path\\":" & my jsonString(itemPath) & ",\\"x\\":" & (item 1 of p as text) & ",\\"y\\":" & (item 2 of p as text) & "}" & linefeed
            end repeat
            return out
        end tell
        """
    }

    public static func moveItems(_ moves: [IconMove]) -> String {
        let lines = moves.flatMap { move in
            if let path = move.path {
                [
                    "    set targetItem to POSIX file \(AppleScriptEscaper.stringLiteral(path)) as alias",
                    "    set desktop position of targetItem to {\(move.position.x), \(move.position.y)}"
                ]
            } else {
                [
                    "    set desktop position of item \(AppleScriptEscaper.stringLiteral(move.name)) of desktop to {\(move.position.x), \(move.position.y)}"
                ]
            }
        }
        return (["tell application \"Finder\""] + lines + ["end tell"]).joined(separator: "\n")
    }

    static func setDesktopArrangementNotArranged() -> String {
        """
        tell application "Finder"
            tell icon view options of window of desktop
                set arrangement to not arranged
            end tell
        end tell
        """
    }

    static func quitFinder() -> String {
        "tell application \"Finder\" to quit"
    }
}
