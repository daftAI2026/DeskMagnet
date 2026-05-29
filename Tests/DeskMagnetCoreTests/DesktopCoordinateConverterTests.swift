/**
 * [INPUT]: 依赖 Testing 与 DeskMagnetCore 的 DesktopCoordinateConverter。
 * [OUTPUT]: 提供 AppKit 左下角坐标到 Finder 左上角桌面坐标的转换测试。
 * [POS]: DeskMagnetCoreTests 的坐标系测试，防止图标被错误吸到窗口下方以外的位置。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Testing
@testable import DeskMagnetCore

@Suite("Desktop coordinate converter")
struct DesktopCoordinateConverterTests {
    @Test("Converts AppKit window frame into Finder top-left desktop frame")
    func convertsWindowFrame() {
        let converter = DesktopCoordinateConverter(globalMaxY: 1000)

        let frame = converter.windowFrameFromAppKit(x: 160, y: 420, width: 800, height: 520)

        #expect(frame == WindowFrame(x: 160, y: 60, width: 800, height: 520))
    }

    @Test("Converts AppKit screen frame into Finder top-left screen frame")
    func convertsScreenFrame() {
        let converter = DesktopCoordinateConverter(globalMaxY: 1000)

        let screen = converter.screenFrameFromAppKit(x: 0, y: 0, width: 1440, height: 900)

        #expect(screen == ScreenFrame(x: 0, y: 100, width: 1440, height: 900))
    }
}
