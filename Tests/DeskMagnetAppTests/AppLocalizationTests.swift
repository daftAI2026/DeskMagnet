/**
 * [INPUT]: 依赖 Testing 与 DeskMagnetApp 的 AppStrings/AppLanguage。
 * [OUTPUT]: 提供语言菜单顺序、CJK 主标题断行、完成态标题、权限提示与新增欧洲/印度语言文案回归测试。
 * [POS]: DeskMagnetAppTests 的本地化测试，防止成功态和产品名再次出现机器化硬翻译。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Testing
@testable import DeskMagnetApp

@Suite("App localization")
struct AppLocalizationTests {
    @Test("Language menu follows supported localized display order")
    func languageMenuOrder() {
        #expect(AppLanguage.allCases.map(\.rawValue) == [
            "en",
            "zh-Hans",
            "ja",
            "zh-Hant",
            "es",
            "fr",
            "pt",
            "ko",
            "de",
            "hi"
        ])
        #expect(AppLanguage.allCases.map(\.nativeName) == [
            "English",
            "简体中文",
            "日本語",
            "繁體中文",
            "Español",
            "Français",
            "Português",
            "한국어",
            "Deutsch",
            "हिन्दी"
        ])
    }

    @Test("Localized app names and badges read naturally")
    func appNamesAndBadges() {
        #expect(AppStrings.values(for: .simplifiedChinese).badge == "革命性创新技术，优化电脑使用体验")
        #expect(AppStrings.values(for: .simplifiedChinese).idleTitle == "一键清理，还你干净桌面")
        #expect(AppStrings.values(for: .traditionalChinese).badge == "革命性創新技術，優化電腦使用體驗")
        #expect(AppStrings.values(for: .traditionalChinese).idleTitle == "一鍵清理，還你乾淨桌面")
        #expect(AppStrings.values(for: .english).appName == "Desktop Cleaner")
        #expect(AppStrings.values(for: .english).badge == "Revolutionary tech for a better Mac")
        #expect(AppStrings.values(for: .english).idleTitle == "One-click cleanup for a clean desktop")
        #expect(AppStrings.values(for: .japanese).appName == "デスクトップクリーナー")
        #expect(AppStrings.values(for: .japanese).badge == "Macを軽やかに整えるスマート技術")
        #expect(AppStrings.values(for: .japanese).idleTitle == "ワンクリックで\nデスクトップをきれいに")
        #expect(AppStrings.values(for: .korean).appName == "데스크톱 클리너")
        #expect(AppStrings.values(for: .korean).badge == "Mac을 깔끔하게 정리하는 스마트 기술")
        #expect(AppStrings.values(for: .korean).idleTitle == "한 번의 클릭으로 깨끗한\n데스크톱을 돌려드립니다")
    }

    @Test("CJK hero titles use deliberate line breaks")
    func cjkHeroTitleLineBreaks() {
        #expect(AppStrings.values(for: .japanese).idleTitle.split(separator: "\n").map(String.init) == [
            "ワンクリックで",
            "デスクトップをきれいに"
        ])
        #expect(AppStrings.values(for: .korean).idleTitle.split(separator: "\n").map(String.init) == [
            "한 번의 클릭으로 깨끗한",
            "데스크톱을 돌려드립니다"
        ])
    }

    @Test("New localized app names avoid literal Master branding")
    func newLocalizedAppNames() throws {
        let spanish = try #require(AppLanguage(rawValue: "es"))
        let french = try #require(AppLanguage(rawValue: "fr"))
        let portuguese = try #require(AppLanguage(rawValue: "pt"))
        let german = try #require(AppLanguage(rawValue: "de"))
        let hindi = try #require(AppLanguage(rawValue: "hi"))

        #expect(AppStrings.values(for: spanish).appName == "Limpiador de escritorio")
        #expect(AppStrings.values(for: french).appName == "Nettoyeur de bureau")
        #expect(AppStrings.values(for: portuguese).appName == "Limpador de Desktop")
        #expect(AppStrings.values(for: german).appName == "Desktop Cleaner")
        #expect(AppStrings.values(for: hindi).appName == "डेस्कटॉप क्लीनर")
    }

    @Test("English badge is short enough for the title bar")
    func englishBadgeFitsTitleBar() {
        #expect(AppStrings.values(for: .english).badge.count <= 40)
    }

    @Test("Attached title uses natural product wording")
    func attachedTitleWording() {
        #expect(AppStrings.values(for: .simplifiedChinese).attachedTitle(iconCount: 29) == "清理完成，已整理 29 个图标")
        #expect(AppStrings.values(for: .traditionalChinese).attachedTitle(iconCount: 29) == "清理完成，已整理 29 個圖示")
        #expect(AppStrings.values(for: .japanese).attachedTitle(iconCount: 29) == "29個の項目を整理しました")
        #expect(AppStrings.values(for: .korean).attachedTitle(iconCount: 29) == "29개 항목 정리 완료")
    }

    @Test("New localized attached titles use natural wording")
    func newLocalizedAttachedTitleWording() throws {
        let spanish = try #require(AppLanguage(rawValue: "es"))
        let french = try #require(AppLanguage(rawValue: "fr"))
        let portuguese = try #require(AppLanguage(rawValue: "pt"))
        let german = try #require(AppLanguage(rawValue: "de"))
        let hindi = try #require(AppLanguage(rawValue: "hi"))

        #expect(AppStrings.values(for: spanish).attachedTitle(iconCount: 1) == "1 icono ordenado")
        #expect(AppStrings.values(for: spanish).attachedTitle(iconCount: 29) == "29 iconos ordenados")
        #expect(AppStrings.values(for: french).attachedTitle(iconCount: 1) == "1 icône rangée")
        #expect(AppStrings.values(for: french).attachedTitle(iconCount: 29) == "29 icônes rangées")
        #expect(AppStrings.values(for: portuguese).attachedTitle(iconCount: 1) == "1 ícone organizado")
        #expect(AppStrings.values(for: portuguese).attachedTitle(iconCount: 29) == "29 ícones organizados")
        #expect(AppStrings.values(for: german).attachedTitle(iconCount: 1) == "1 Symbol aufgeräumt")
        #expect(AppStrings.values(for: german).attachedTitle(iconCount: 29) == "29 Symbole aufgeräumt")
        #expect(AppStrings.values(for: hindi).attachedTitle(iconCount: 1) == "1 आइटम व्यवस्थित")
        #expect(AppStrings.values(for: hindi).attachedTitle(iconCount: 29) == "29 आइटम व्यवस्थित")
    }

    @Test("English attached title pluralizes item")
    func englishAttachedTitlePluralization() {
        let strings = AppStrings.values(for: .english)

        #expect(strings.attachedTitle(iconCount: 1) == "1 desktop icon cleaned")
        #expect(strings.attachedTitle(iconCount: 29) == "29 desktop icons cleaned")
    }

    @Test("Permission guidance uses localized app names and system paths")
    func permissionGuidance() {
        #expect(AppStrings.values(for: .simplifiedChinese).automationPermissionRequired == "需要允许桌面清理大师控制 Finder。请前往：系统设置 > 隐私与安全性 > 自动化。")
        #expect(AppStrings.values(for: .english).automationPermissionRequired == "Allow Desktop Cleaner to control Finder in System Settings > Privacy & Security > Automation.")
        #expect(AppStrings.values(for: .japanese).automationPermissionRequired == "システム設定 > プライバシーとセキュリティ > オートメーションで、デスクトップクリーナーによるFinderの制御を許可してください。")
        #expect(AppStrings.values(for: .korean).automationPermissionRequired == "시스템 설정 > 개인정보 보호 및 보안 > 자동화에서 데스크톱 클리너가 Finder를 제어하도록 허용하세요.")
    }

    @Test("Japanese Korean and Hindi user-facing copy avoids icon nouns")
    func avoidsIconNounsWhereTheyReadPoorly() {
        let forbiddenTokens = [
            "आइकन", "アイコン", "아이콘"
        ]

        let visibleCopy = [AppLanguage.japanese, .korean, .hindi]
            .flatMap { language in
            let strings = AppStrings.values(for: language)
            return [
                strings.attachedTitle(iconCount: 1),
                strings.attachedTitle(iconCount: 29),
                strings.restoringSubtitle,
                strings.manyIconsWarning,
                strings.tooManyIconsWarning
            ]
        }

        for token in forbiddenTokens {
            #expect(!visibleCopy.contains { $0.contains(token) })
        }
    }

    @Test("System language resolver covers every supported locale family")
    func systemLanguageResolver() {
        #expect(AppLanguage.systemPreferred(from: ["es-MX"]) == AppLanguage(rawValue: "es"))
        #expect(AppLanguage.systemPreferred(from: ["fr-CA"]) == AppLanguage(rawValue: "fr"))
        #expect(AppLanguage.systemPreferred(from: ["pt-BR"]) == AppLanguage(rawValue: "pt"))
        #expect(AppLanguage.systemPreferred(from: ["de-DE"]) == AppLanguage(rawValue: "de"))
        #expect(AppLanguage.systemPreferred(from: ["hi-IN"]) == AppLanguage(rawValue: "hi"))
    }

    @Test("Localized strings avoid machine translation verbs")
    func avoidsMachineTranslationVerbs() {
        let allStrings = AppLanguage.allCases.map { AppStrings.values(for: $0) }

        #expect(!allStrings.contains { $0.attachedTitle(iconCount: 29).contains("processed") })
        #expect(!allStrings.contains { $0.appName.contains("Master") })
        #expect(!allStrings.contains { $0.attachedTitle(iconCount: 29).contains("処理") })
        #expect(!allStrings.contains { $0.attachedTitle(iconCount: 29).contains("처리") })
    }
}
