/**
 * [INPUT]: 依赖 AppKit 风格左下角坐标输入与全局屏幕最高 y。
 * [OUTPUT]: 对外提供 DesktopCoordinateConverter，将窗口/屏幕转换为 Finder 左上角桌面坐标。
 * [POS]: DeskMagnetCore 的坐标系边界，防止 AppKit 与 Finder 坐标语义混用。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

public struct DesktopCoordinateConverter: Sendable {
    private let globalMaxY: Int

    public init(globalMaxY: Int) {
        self.globalMaxY = globalMaxY
    }

    public func windowFrameFromAppKit(x: Int, y: Int, width: Int, height: Int) -> WindowFrame {
        WindowFrame(x: x, y: globalMaxY - (y + height), width: width, height: height)
    }

    public func screenFrameFromAppKit(x: Int, y: Int, width: Int, height: Int) -> ScreenFrame {
        ScreenFrame(x: x, y: globalMaxY - (y + height), width: width, height: height)
    }
}
