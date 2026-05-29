/**
 * [INPUT]: 依赖 Testing 与 DeskMagnetCore 的 IconPerformancePolicy。
 * [OUTPUT]: 提供图标数量分级策略测试。
 * [POS]: DeskMagnetCoreTests 的 P2 性能策略测试，约束拖动跟随频率与大量图标提示。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Testing
@testable import DeskMagnetCore

@Suite("Icon performance policy")
struct PerformancePolicyTests {
    @Test("Uses fast realtime sync for small desktops")
    func smallDesktopPolicy() {
        let strategy = IconPerformancePolicy.strategy(for: 30)

        #expect(strategy.mode == .allDuringDrag)
        #expect(strategy.throttleMilliseconds == 100)
        #expect(strategy.warning == nil)
    }

    @Test("Uses slower realtime sync for medium desktops")
    func mediumDesktopPolicy() {
        let strategy = IconPerformancePolicy.strategy(for: 100)

        #expect(strategy.mode == .allDuringDrag)
        #expect(strategy.throttleMilliseconds == 200)
    }

    @Test("Samples during drag for large desktops and disables realtime for huge desktops")
    func largeDesktopPolicy() {
        let large = IconPerformancePolicy.strategy(for: 150)
        let huge = IconPerformancePolicy.strategy(for: 301)

        #expect(large.mode == .sampledDuringDrag(sampleLimit: 60))
        #expect(large.warning != nil)
        #expect(huge.mode == .finalOnly)
        #expect(huge.warning != nil)
    }
}
