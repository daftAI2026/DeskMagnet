/**
 * [INPUT]: 依赖 AppleScriptEscaper 与 IconMove 生成 Finder AppleScript。
 * [OUTPUT]: 对外提供 FinderIconScript.readDesktopItems() 和 moveItems(_:)。
 * [POS]: DeskMagnetCore 的 Finder 脚本构造层，不执行命令，只产生命令文本。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

public enum FinderIconScript {
    public static func readDesktopItems() -> String {
        """
        tell application "Finder"
            set out to ""
            repeat with i from 1 to count every item of desktop
                set anItem to item i of desktop
                set p to desktop position of anItem
                set itemName to name of anItem as text
                set itemPath to POSIX path of (anItem as alias)
                set out to out & itemName & tab & itemPath & tab & (item 1 of p as text) & tab & (item 2 of p as text) & linefeed
            end repeat
            return out
        end tell
        """
    }

    public static func moveItems(_ moves: [IconMove]) -> String {
        let lines = moves.map { move in
            "    set desktop position of item \(AppleScriptEscaper.stringLiteral(move.name)) of desktop to {\(move.position.x), \(move.position.y)}"
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
