/**
 * [INPUT]: 依赖 Testing 与 DeskMagnetApp 的 AppStrings/AppLanguage。
 * [OUTPUT]: 提供完成态标题的中英日韩文案回归测试。
 * [POS]: DeskMagnetAppTests 的本地化测试，防止成功态再次出现机器化“处理 processed”等表达。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Testing
@testable import DeskMagnetApp

@Suite("App localization")
struct AppLocalizationTests {
    @Test("Localized app names and badges read naturally")
    func appNamesAndBadges() {
        #expect(AppStrings.values(for: .simplifiedChinese).badge == "革命性创新技术，优化电脑使用体验")
        #expect(AppStrings.values(for: .simplifiedChinese).idleTitle == "一键清理，还你干净桌面")
        #expect(AppStrings.values(for: .traditionalChinese).badge == "革命性創新技術，優化電腦使用體驗")
        #expect(AppStrings.values(for: .traditionalChinese).idleTitle == "一鍵清理，還你乾淨桌面")
        #expect(AppStrings.values(for: .english).appName == "Desktop Cleanup Master")
        #expect(AppStrings.values(for: .english).badge == "Revolutionary innovation technology, optimized for your computer experience")
        #expect(AppStrings.values(for: .english).idleTitle == "One-click cleanup for a clean desktop")
        #expect(AppStrings.values(for: .japanese).badge == "革命的な革新技術で、コンピュータ体験を最適化")
        #expect(AppStrings.values(for: .japanese).idleTitle == "ワンクリックで、きれいなデスクトップに")
        #expect(AppStrings.values(for: .korean).badge == "혁명적인 혁신 기술로 컴퓨터 사용 경험을 최적화")
        #expect(AppStrings.values(for: .korean).idleTitle == "한 번의 클릭으로 깨끗한 데스크톱을 돌려드립니다")
    }

    @Test("Attached title uses natural product wording")
    func attachedTitleWording() {
        #expect(AppStrings.values(for: .simplifiedChinese).attachedTitle(iconCount: 29) == "清理完成，已整理 29 个图标")
        #expect(AppStrings.values(for: .traditionalChinese).attachedTitle(iconCount: 29) == "清理完成，已整理 29 個圖示")
        #expect(AppStrings.values(for: .japanese).attachedTitle(iconCount: 29) == "29個の項目を整理しました")
        #expect(AppStrings.values(for: .korean).attachedTitle(iconCount: 29) == "29개 항목 정리 완료")
    }

    @Test("English attached title pluralizes item")
    func englishAttachedTitlePluralization() {
        let strings = AppStrings.values(for: .english)

        #expect(strings.attachedTitle(iconCount: 1) == "1 item cleaned")
        #expect(strings.attachedTitle(iconCount: 29) == "29 items cleaned")
    }

    @Test("Permission guidance uses localized app names and system paths")
    func permissionGuidance() {
        #expect(AppStrings.values(for: .simplifiedChinese).automationPermissionRequired == "需要允许桌面清理大师控制 Finder。请前往：系统设置 > 隐私与安全性 > 自动化。")
        #expect(AppStrings.values(for: .english).automationPermissionRequired == "Allow Desktop Cleanup Master to control Finder in System Settings > Privacy & Security > Automation.")
        #expect(AppStrings.values(for: .japanese).automationPermissionRequired == "システム設定 > プライバシーとセキュリティ > オートメーションで、デスクトップ整理マスターによるFinderの制御を許可してください。")
        #expect(AppStrings.values(for: .korean).automationPermissionRequired == "시스템 설정 > 개인정보 보호 및 보안 > 자동화에서 데스크톱 정리 마스터가 Finder를 제어하도록 허용하세요.")
    }

    @Test("Localized strings avoid machine translation verbs")
    func avoidsMachineTranslationVerbs() {
        let allStrings = AppLanguage.allCases.map { AppStrings.values(for: $0) }

        #expect(!allStrings.contains { $0.attachedTitle(iconCount: 29).contains("processed") })
        #expect(!allStrings.contains { $0.attachedTitle(iconCount: 29).contains("処理") })
        #expect(!allStrings.contains { $0.attachedTitle(iconCount: 29).contains("처리") })
    }
}
