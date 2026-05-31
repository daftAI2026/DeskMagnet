/**
 * [INPUT]: 依赖 Foundation/UserDefaults 判断系统语言并持久化用户语言选择。
 * [OUTPUT]: 提供 AppLanguage、AppStrings、AppLanguageStore，统一本地化软件名、窗口与菜单文案。
 * [POS]: DeskMagnetApp 的本地化单一真相源，被 AppDelegate 与 ContentView 消费。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Combine
import Foundation

enum AppLanguage: String, CaseIterable, Equatable {
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    case english = "en"
    case japanese = "ja"
    case korean = "ko"

    var nativeName: String {
        switch self {
        case .simplifiedChinese:
            "简体中文"
        case .traditionalChinese:
            "繁體中文"
        case .english:
            "English"
        case .japanese:
            "日本語"
        case .korean:
            "한국어"
        }
    }

    static func systemPreferred(from identifiers: [String] = Locale.preferredLanguages) -> AppLanguage {
        for identifier in identifiers.map({ $0.lowercased() }) {
            if identifier.hasPrefix("zh-hant")
                || identifier.hasPrefix("zh-tw")
                || identifier.hasPrefix("zh-hk")
                || identifier.hasPrefix("zh-mo")
                || identifier.contains("hant") {
                return .traditionalChinese
            }
            if identifier.hasPrefix("zh") {
                return .simplifiedChinese
            }
            if identifier.hasPrefix("ja") {
                return .japanese
            }
            if identifier.hasPrefix("ko") {
                return .korean
            }
            if identifier.hasPrefix("en") {
                return .english
            }
        }
        return .english
    }
}

struct AppStrings: Equatable {
    let appName: String
    let badge: String
    let idleTitle: String
    let cleanButton: String
    let cleaningTitle: String
    let attachedTitleFormat: String
    let attachedTitleSingularFormat: String?
    let restoringTitle: String
    let restoringSubtitle: String
    let failedTitle: String
    let windowPositionUnavailable: String
    let automationPermissionRequired: String
    let unfinishedTitle: String
    let unfinishedMessage: String
    let restoreNow: String
    let later: String
    let fatalTitle: String
    let menuClean: String
    let menuRestore: String
    let menuLanguage: String
    let menuFollowSystem: String
    let menuQuit: String
    let permissionFootnote: String

    static func values(for language: AppLanguage) -> AppStrings {
        switch language {
        case .simplifiedChinese:
            AppStrings(
                appName: "桌面清理大师",
                badge: "革命性创新技术，优化电脑使用体验",
                idleTitle: "一键清理，还你干净桌面",
                cleanButton: "一键清理",
                cleaningTitle: "正在清理桌面...",
                attachedTitleFormat: "清理完成，已整理 %d 个图标",
                attachedTitleSingularFormat: nil,
                restoringTitle: "正在恢复桌面",
                restoringSubtitle: "图标和 Finder 设置将恢复到启动前状态",
                failedTitle: "清理失败",
                windowPositionUnavailable: "无法读取主窗口位置。",
                automationPermissionRequired: "需要允许桌面清理大师控制 Finder。请前往：系统设置 > 隐私与安全性 > 自动化。",
                unfinishedTitle: "检测到上次桌面未恢复",
                unfinishedMessage: "是否现在恢复？",
                restoreNow: "立即恢复",
                later: "稍后",
                fatalTitle: "桌面清理大师启动失败",
                menuClean: "一键清理",
                menuRestore: "还原桌面",
                menuLanguage: "语言",
                menuFollowSystem: "跟随系统",
                menuQuit: "退出桌面清理大师",
                permissionFootnote: "需要允许桌面清理大师控制 Finder"
            )
        case .traditionalChinese:
            AppStrings(
                appName: "桌面清理大師",
                badge: "革命性創新技術，優化電腦使用體驗",
                idleTitle: "一鍵清理，還你乾淨桌面",
                cleanButton: "一鍵清理",
                cleaningTitle: "正在清理桌面...",
                attachedTitleFormat: "清理完成，已整理 %d 個圖示",
                attachedTitleSingularFormat: nil,
                restoringTitle: "正在恢復桌面",
                restoringSubtitle: "圖示和 Finder 設定將恢復到啟動前狀態",
                failedTitle: "清理失敗",
                windowPositionUnavailable: "無法讀取主視窗位置。",
                automationPermissionRequired: "需要允許桌面清理大師控制 Finder。請前往：系統設定 > 隱私權與安全性 > 自動化。",
                unfinishedTitle: "偵測到上次桌面尚未恢復",
                unfinishedMessage: "是否現在恢復？",
                restoreNow: "立即恢復",
                later: "稍後",
                fatalTitle: "桌面清理大師啟動失敗",
                menuClean: "一鍵清理",
                menuRestore: "還原桌面",
                menuLanguage: "語言",
                menuFollowSystem: "跟隨系統",
                menuQuit: "退出桌面清理大師",
                permissionFootnote: "需要允許桌面清理大師控制 Finder"
            )
        case .english:
            AppStrings(
                appName: "Desktop Cleanup Master",
                badge: "Revolutionary innovation technology, optimized for your computer experience",
                idleTitle: "One-click cleanup for a clean desktop",
                cleanButton: "Clean Desktop",
                cleaningTitle: "Cleaning desktop...",
                attachedTitleFormat: "%d items cleaned",
                attachedTitleSingularFormat: "%d item cleaned",
                restoringTitle: "Restoring desktop",
                restoringSubtitle: "Icons and Finder settings will return to their previous state",
                failedTitle: "Cleanup failed",
                windowPositionUnavailable: "Unable to read the main window position.",
                automationPermissionRequired: "Allow Desktop Cleanup Master to control Finder in System Settings > Privacy & Security > Automation.",
                unfinishedTitle: "Desktop was not restored last time",
                unfinishedMessage: "Restore it now?",
                restoreNow: "Restore Now",
                later: "Later",
                fatalTitle: "Desktop Cleanup Master failed to launch",
                menuClean: "Clean Desktop",
                menuRestore: "Restore Desktop",
                menuLanguage: "Language",
                menuFollowSystem: "Follow System",
                menuQuit: "Quit Desktop Cleanup Master",
                permissionFootnote: "Allow Desktop Cleanup Master to control Finder"
            )
        case .japanese:
            AppStrings(
                appName: "デスクトップ整理マスター",
                badge: "革命的な革新技術で、コンピュータ体験を最適化",
                idleTitle: "ワンクリックで、きれいなデスクトップに",
                cleanButton: "一括整理",
                cleaningTitle: "デスクトップを整理中...",
                attachedTitleFormat: "%d個の項目を整理しました",
                attachedTitleSingularFormat: nil,
                restoringTitle: "デスクトップを復元中",
                restoringSubtitle: "アイコンとFinder設定を起動前の状態に戻します",
                failedTitle: "整理に失敗しました",
                windowPositionUnavailable: "メインウィンドウの位置を読み取れません。",
                automationPermissionRequired: "システム設定 > プライバシーとセキュリティ > オートメーションで、デスクトップ整理マスターによるFinderの制御を許可してください。",
                unfinishedTitle: "前回のデスクトップが復元されていません",
                unfinishedMessage: "今すぐ復元しますか？",
                restoreNow: "今すぐ復元",
                later: "後で",
                fatalTitle: "DeskMagnet を起動できません",
                menuClean: "一括整理",
                menuRestore: "デスクトップを復元",
                menuLanguage: "言語",
                menuFollowSystem: "システム言語に従う",
                menuQuit: "デスクトップ整理マスターを終了",
                permissionFootnote: "Finderの制御を許可してください"
            )
        case .korean:
            AppStrings(
                appName: "데스크톱 정리 마스터",
                badge: "혁명적인 혁신 기술로 컴퓨터 사용 경험을 최적화",
                idleTitle: "한 번의 클릭으로 깨끗한 데스크톱을 돌려드립니다",
                cleanButton: "한 번에 정리",
                cleaningTitle: "데스크톱 정리 중...",
                attachedTitleFormat: "%d개 항목 정리 완료",
                attachedTitleSingularFormat: nil,
                restoringTitle: "데스크톱 복원 중",
                restoringSubtitle: "아이콘과 Finder 설정을 실행 전 상태로 되돌립니다",
                failedTitle: "정리 실패",
                windowPositionUnavailable: "메인 창 위치를 읽을 수 없습니다.",
                automationPermissionRequired: "시스템 설정 > 개인정보 보호 및 보안 > 자동화에서 데스크톱 정리 마스터가 Finder를 제어하도록 허용하세요.",
                unfinishedTitle: "지난번 데스크톱이 복원되지 않았습니다",
                unfinishedMessage: "지금 복원할까요?",
                restoreNow: "지금 복원",
                later: "나중에",
                fatalTitle: "데스크톱 정리 마스터 실행 실패",
                menuClean: "한 번에 정리",
                menuRestore: "데스크톱 복원",
                menuLanguage: "언어",
                menuFollowSystem: "시스템 언어 사용",
                menuQuit: "데스크톱 정리 마스터 종료",
                permissionFootnote: "Finder 제어를 허용하세요"
            )
        }
    }

    func attachedTitle(iconCount: Int) -> String {
        if iconCount == 1, let attachedTitleSingularFormat {
            return String(format: attachedTitleSingularFormat, iconCount)
        }
        return String(format: attachedTitleFormat, iconCount)
    }
}

@MainActor
final class AppLanguageStore: ObservableObject {
    @Published private(set) var selectedLanguage: AppLanguage?

    private let defaults: UserDefaults
    private let key = "DeskMagnet.SelectedLanguage"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let rawValue = defaults.string(forKey: key) {
            selectedLanguage = AppLanguage(rawValue: rawValue)
        }
    }

    var effectiveLanguage: AppLanguage {
        selectedLanguage ?? AppLanguage.systemPreferred()
    }

    var strings: AppStrings {
        AppStrings.values(for: effectiveLanguage)
    }

    func select(_ language: AppLanguage?) {
        selectedLanguage = language
        if let language {
            defaults.set(language.rawValue, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }
}
