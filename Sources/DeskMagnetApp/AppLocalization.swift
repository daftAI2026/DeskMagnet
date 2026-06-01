/**
 * [INPUT]: 依赖 Foundation/UserDefaults 判断系统语言，依赖 DeskMagnetCore.IconPerformanceNotice 映射性能提示。
 * [OUTPUT]: 提供 AppLanguage、AppStrings、AppLanguageStore，统一本地化软件名、窗口、菜单、权限与性能提示文案。
 * [POS]: DeskMagnetApp 的本地化单一真相源，被 AppDelegate 与 ContentView 消费。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import Combine
import DeskMagnetCore
import Foundation

enum AppLanguage: String, CaseIterable, Equatable, Hashable {
    case english = "en"
    case simplifiedChinese = "zh-Hans"
    case japanese = "ja"
    case traditionalChinese = "zh-Hant"
    case spanish = "es"
    case french = "fr"
    case portuguese = "pt"
    case korean = "ko"
    case german = "de"
    case hindi = "hi"

    var nativeName: String {
        Self.nativeNames[self] ?? rawValue
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
            let family = identifier.split { $0 == "-" || $0 == "_" }.first.map(String.init) ?? identifier
            if let language = Self.languageFamilies[family] {
                return language
            }
        }
        return .english
    }

    private static let nativeNames: [AppLanguage: String] = [
        .english: "English",
        .simplifiedChinese: "简体中文",
        .japanese: "日本語",
        .traditionalChinese: "繁體中文",
        .spanish: "Español",
        .french: "Français",
        .portuguese: "Português",
        .korean: "한국어",
        .german: "Deutsch",
        .hindi: "हिन्दी"
    ]

    private static let languageFamilies: [String: AppLanguage] = [
        "en": .english,
        "zh": .simplifiedChinese,
        "ja": .japanese,
        "es": .spanish,
        "fr": .french,
        "pt": .portuguese,
        "ko": .korean,
        "de": .german,
        "hi": .hindi
    ]
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
    let manyIconsWarning: String
    let tooManyIconsWarning: String

    static func values(for language: AppLanguage) -> AppStrings {
        valuesByLanguage[language] ?? valuesByLanguage[.english]!
    }

    func attachedTitle(iconCount: Int) -> String {
        if iconCount == 1, let attachedTitleSingularFormat {
            return String(format: attachedTitleSingularFormat, iconCount)
        }
        return String(format: attachedTitleFormat, iconCount)
    }

    func performanceWarning(for notice: IconPerformanceNotice?) -> String? {
        switch notice {
        case .manyIcons:
            manyIconsWarning
        case .tooManyIcons:
            tooManyIconsWarning
        case nil:
            nil
        }
    }

    private static let valuesByLanguage: [AppLanguage: AppStrings] = [
        .english: AppStrings(
            appName: "Desktop Cleaner",
            badge: "Revolutionary tech for a better Mac",
            idleTitle: "One-click cleanup for a clean desktop",
            cleanButton: "Clean Desktop",
            cleaningTitle: "Cleaning desktop...",
            attachedTitleFormat: "%d desktop icons cleaned",
            attachedTitleSingularFormat: "%d desktop icon cleaned",
            restoringTitle: "Restoring desktop",
            restoringSubtitle: "Desktop icons and Finder settings will return to their previous state",
            failedTitle: "Cleanup failed",
            windowPositionUnavailable: "Unable to read the main window position.",
            automationPermissionRequired: "Allow Desktop Cleaner to control Finder in System Settings > Privacy & Security > Automation.",
            unfinishedTitle: "Desktop was not restored last time",
            unfinishedMessage: "Restore it now?",
            restoreNow: "Restore Now",
            later: "Later",
            fatalTitle: "Desktop Cleaner failed to launch",
            menuClean: "Clean Desktop",
            menuRestore: "Restore Desktop",
            menuLanguage: "Language",
            menuFollowSystem: "Follow System",
            menuQuit: "Quit Desktop Cleaner",
            permissionFootnote: "Allow Desktop Cleaner to control Finder",
            manyIconsWarning: "There are many desktop icons, so dragging will update a sample first and finish syncing after release.",
            tooManyIconsWarning: "There are over 300 desktop icons, so dragging pauses live updates and syncs everything after release."
        ),
        .simplifiedChinese: AppStrings(
            appName: "桌面清理大师",
            badge: "革命性创新技术，优化电脑使用体验",
            idleTitle: "一键清理，还你干净桌面",
            cleanButton: "一键清理",
            cleaningTitle: "正在清理桌面...",
            attachedTitleFormat: "清理完成，已整理 %d 个图标",
            attachedTitleSingularFormat: nil,
            restoringTitle: "正在恢复桌面",
            restoringSubtitle: "桌面图标和 Finder 设置将恢复到启动前状态",
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
            permissionFootnote: "需要允许桌面清理大师控制 Finder",
            manyIconsWarning: "桌面图标较多，拖动时将抽样跟随，松手后全量同步。",
            tooManyIconsWarning: "桌面图标超过 300 个，拖动中暂停实时跟随，松手后全量同步。"
        ),
        .japanese: AppStrings(
            appName: "デスクトップクリーナー",
            badge: "Macを軽やかに整えるスマート技術",
            idleTitle: "ワンクリックで\nデスクトップをきれいに",
            cleanButton: "デスクトップを整理",
            cleaningTitle: "デスクトップを整理中...",
            attachedTitleFormat: "%d個の項目を整理しました",
            attachedTitleSingularFormat: nil,
            restoringTitle: "デスクトップを復元中",
            restoringSubtitle: "デスクトップ項目とFinder設定を起動前の状態に戻します",
            failedTitle: "整理に失敗しました",
            windowPositionUnavailable: "メインウィンドウの位置を読み取れません。",
            automationPermissionRequired: "システム設定 > プライバシーとセキュリティ > オートメーションで、デスクトップクリーナーによるFinderの制御を許可してください。",
            unfinishedTitle: "前回のデスクトップが復元されていません",
            unfinishedMessage: "今すぐ復元しますか？",
            restoreNow: "今すぐ復元",
            later: "後で",
            fatalTitle: "デスクトップクリーナーを起動できません",
            menuClean: "デスクトップを整理",
            menuRestore: "デスクトップを復元",
            menuLanguage: "言語",
            menuFollowSystem: "システム言語に従う",
            menuQuit: "デスクトップクリーナーを終了",
            permissionFootnote: "Finderの制御を許可してください",
            manyIconsWarning: "デスクトップ項目が多いため、ドラッグ中は一部だけ追従し、手を離した後に全体を同期します。",
            tooManyIconsWarning: "デスクトップ項目が300個を超えているため、ドラッグ中の追従を止め、手を離した後に全体を同期します。"
        ),
        .traditionalChinese: AppStrings(
            appName: "桌面清理大師",
            badge: "革命性創新技術，優化電腦使用體驗",
            idleTitle: "一鍵清理，還你乾淨桌面",
            cleanButton: "一鍵清理",
            cleaningTitle: "正在清理桌面...",
            attachedTitleFormat: "清理完成，已整理 %d 個圖示",
            attachedTitleSingularFormat: nil,
            restoringTitle: "正在恢復桌面",
            restoringSubtitle: "桌面圖示和 Finder 設定將恢復到啟動前狀態",
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
            permissionFootnote: "需要允許桌面清理大師控制 Finder",
            manyIconsWarning: "桌面圖示較多，拖曳時將抽樣跟隨，放開後全量同步。",
            tooManyIconsWarning: "桌面圖示超過 300 個，拖曳中暫停即時跟隨，放開後全量同步。"
        ),
        .spanish: AppStrings(
            appName: "Limpiador de escritorio",
            badge: "Tu Mac, limpio en un clic",
            idleTitle: "Un clic para ordenar el escritorio",
            cleanButton: "Limpiar escritorio",
            cleaningTitle: "Limpiando el escritorio...",
            attachedTitleFormat: "%d iconos ordenados",
            attachedTitleSingularFormat: "%d icono ordenado",
            restoringTitle: "Restaurando el escritorio",
            restoringSubtitle: "Los iconos del escritorio y los ajustes de Finder volverán al estado anterior",
            failedTitle: "No se pudo limpiar",
            windowPositionUnavailable: "No se pudo leer la posición de la ventana principal.",
            automationPermissionRequired: "Permite que Limpiador de escritorio controle Finder en Ajustes del Sistema > Privacidad y seguridad > Automatización.",
            unfinishedTitle: "El escritorio no se restauró la última vez",
            unfinishedMessage: "¿Restaurarlo ahora?",
            restoreNow: "Restaurar ahora",
            later: "Más tarde",
            fatalTitle: "Limpiador de escritorio no pudo abrirse",
            menuClean: "Limpiar escritorio",
            menuRestore: "Restaurar escritorio",
            menuLanguage: "Idioma",
            menuFollowSystem: "Usar idioma del sistema",
            menuQuit: "Salir de Limpiador de escritorio",
            permissionFootnote: "Permite el control de Finder",
            manyIconsWarning: "Hay muchos iconos en el escritorio; al arrastrar se moverá una muestra y al soltar se sincronizará todo.",
            tooManyIconsWarning: "Hay más de 300 iconos en el escritorio; se pausa el seguimiento al arrastrar y todo se sincroniza al soltar."
        ),
        .french: AppStrings(
            appName: "Nettoyeur de bureau",
            badge: "Un Mac net en un clic",
            idleTitle: "Un clic pour ranger le bureau",
            cleanButton: "Nettoyer le bureau",
            cleaningTitle: "Nettoyage du bureau...",
            attachedTitleFormat: "%d icônes rangées",
            attachedTitleSingularFormat: "%d icône rangée",
            restoringTitle: "Restauration du bureau",
            restoringSubtitle: "Les icônes du bureau et les réglages Finder reviendront à leur état précédent",
            failedTitle: "Nettoyage impossible",
            windowPositionUnavailable: "Impossible de lire la position de la fenêtre principale.",
            automationPermissionRequired: "Autorisez Nettoyeur de bureau à contrôler Finder dans Réglages Système > Confidentialité et sécurité > Automatisation.",
            unfinishedTitle: "Le bureau n'a pas été restauré la dernière fois",
            unfinishedMessage: "Le restaurer maintenant ?",
            restoreNow: "Restaurer",
            later: "Plus tard",
            fatalTitle: "Nettoyeur de bureau n'a pas pu s'ouvrir",
            menuClean: "Nettoyer le bureau",
            menuRestore: "Restaurer le bureau",
            menuLanguage: "Langue",
            menuFollowSystem: "Suivre le système",
            menuQuit: "Quitter Nettoyeur de bureau",
            permissionFootnote: "Autorisez le contrôle de Finder",
            manyIconsWarning: "Le bureau contient beaucoup d'icônes ; le glisser-déposer en suit une partie puis synchronise tout au relâchement.",
            tooManyIconsWarning: "Le bureau contient plus de 300 icônes ; le suivi en direct est suspendu et tout se synchronise au relâchement."
        ),
        .portuguese: AppStrings(
            appName: "Limpador de Desktop",
            badge: "Seu Mac limpo em um clique",
            idleTitle: "Um clique para organizar o Desktop",
            cleanButton: "Limpar Desktop",
            cleaningTitle: "Limpando o Desktop...",
            attachedTitleFormat: "%d ícones organizados",
            attachedTitleSingularFormat: "%d ícone organizado",
            restoringTitle: "Restaurando o Desktop",
            restoringSubtitle: "Os ícones do Desktop e os ajustes do Finder voltarão ao estado anterior",
            failedTitle: "Não foi possível limpar",
            windowPositionUnavailable: "Não foi possível ler a posição da janela principal.",
            automationPermissionRequired: "Permita que o Limpador de Desktop controle o Finder em Ajustes do Sistema > Privacidade e Segurança > Automação.",
            unfinishedTitle: "O Desktop não foi restaurado da última vez",
            unfinishedMessage: "Restaurar agora?",
            restoreNow: "Restaurar agora",
            later: "Mais tarde",
            fatalTitle: "O Limpador de Desktop não pôde abrir",
            menuClean: "Limpar Desktop",
            menuRestore: "Restaurar Desktop",
            menuLanguage: "Idioma",
            menuFollowSystem: "Usar idioma do sistema",
            menuQuit: "Sair do Limpador de Desktop",
            permissionFootnote: "Permita o controle do Finder",
            manyIconsWarning: "Há muitos ícones no Desktop; ao arrastar, uma amostra acompanha e tudo sincroniza ao soltar.",
            tooManyIconsWarning: "Há mais de 300 ícones no Desktop; o acompanhamento ao arrastar pausa e tudo sincroniza ao soltar."
        ),
        .korean: AppStrings(
            appName: "데스크톱 클리너",
            badge: "Mac을 깔끔하게 정리하는 스마트 기술",
            idleTitle: "한 번의 클릭으로 깨끗한\n데스크톱을 돌려드립니다",
            cleanButton: "데스크톱 정리",
            cleaningTitle: "데스크톱 정리 중...",
            attachedTitleFormat: "%d개 항목 정리 완료",
            attachedTitleSingularFormat: nil,
            restoringTitle: "데스크톱 복원 중",
            restoringSubtitle: "데스크톱 항목과 Finder 설정을 실행 전 상태로 되돌립니다",
            failedTitle: "정리 실패",
            windowPositionUnavailable: "메인 창 위치를 읽을 수 없습니다.",
            automationPermissionRequired: "시스템 설정 > 개인정보 보호 및 보안 > 자동화에서 데스크톱 클리너가 Finder를 제어하도록 허용하세요.",
            unfinishedTitle: "지난번 데스크톱이 복원되지 않았습니다",
            unfinishedMessage: "지금 복원할까요?",
            restoreNow: "지금 복원",
            later: "나중에",
            fatalTitle: "데스크톱 클리너 실행 실패",
            menuClean: "데스크톱 정리",
            menuRestore: "데스크톱 복원",
            menuLanguage: "언어",
            menuFollowSystem: "시스템 언어 사용",
            menuQuit: "데스크톱 클리너 종료",
            permissionFootnote: "Finder 제어를 허용하세요",
            manyIconsWarning: "데스크톱 항목이 많아 드래그 중에는 일부만 따라가고, 손을 놓으면 전체를 동기화합니다.",
            tooManyIconsWarning: "데스크톱 항목이 300개를 넘어 드래그 중 실시간 추적을 멈추고, 손을 놓으면 전체를 동기화합니다."
        ),
        .german: AppStrings(
            appName: "Desktop Cleaner",
            badge: "Ein sauberer Mac mit einem Klick",
            idleTitle: "Desktop mit einem Klick aufräumen",
            cleanButton: "Desktop aufräumen",
            cleaningTitle: "Desktop wird aufgeräumt...",
            attachedTitleFormat: "%d Symbole aufgeräumt",
            attachedTitleSingularFormat: "%d Symbol aufgeräumt",
            restoringTitle: "Desktop wird wiederhergestellt",
            restoringSubtitle: "Desktop-Symbole und Finder-Einstellungen werden zurückgesetzt",
            failedTitle: "Aufräumen fehlgeschlagen",
            windowPositionUnavailable: "Die Position des Hauptfensters konnte nicht gelesen werden.",
            automationPermissionRequired: "Erlaube Desktop Cleaner, den Finder unter Systemeinstellungen > Datenschutz & Sicherheit > Automation zu steuern.",
            unfinishedTitle: "Der Desktop wurde beim letzten Mal nicht wiederhergestellt",
            unfinishedMessage: "Jetzt wiederherstellen?",
            restoreNow: "Wiederherstellen",
            later: "Später",
            fatalTitle: "Desktop Cleaner konnte nicht gestartet werden",
            menuClean: "Desktop aufräumen",
            menuRestore: "Desktop wiederherstellen",
            menuLanguage: "Sprache",
            menuFollowSystem: "Systemsprache verwenden",
            menuQuit: "Desktop Cleaner beenden",
            permissionFootnote: "Finder-Steuerung erlauben",
            manyIconsWarning: "Auf dem Desktop liegen viele Symbole; beim Ziehen folgt zuerst eine Auswahl, nach dem Loslassen wird alles synchronisiert.",
            tooManyIconsWarning: "Auf dem Desktop liegen über 300 Symbole; Live-Folgen wird pausiert und nach dem Loslassen wird alles synchronisiert."
        ),
        .hindi: AppStrings(
            appName: "डेस्कटॉप क्लीनर",
            badge: "एक क्लिक में साफ-सुथरा Mac",
            idleTitle: "एक क्लिक में साफ डेस्कटॉप",
            cleanButton: "डेस्कटॉप साफ करें",
            cleaningTitle: "डेस्कटॉप साफ हो रहा है...",
            attachedTitleFormat: "%d आइटम व्यवस्थित",
            attachedTitleSingularFormat: "%d आइटम व्यवस्थित",
            restoringTitle: "डेस्कटॉप वापस लाया जा रहा है",
            restoringSubtitle: "डेस्कटॉप आइटम और Finder सेटिंग पहले जैसी हो जाएंगी",
            failedTitle: "सफाई विफल रही",
            windowPositionUnavailable: "मुख्य विंडो की स्थिति पढ़ी नहीं जा सकी।",
            automationPermissionRequired: "System Settings > Privacy & Security > Automation में डेस्कटॉप क्लीनर को Finder नियंत्रित करने की अनुमति दें।",
            unfinishedTitle: "पिछली बार डेस्कटॉप वापस नहीं आया",
            unfinishedMessage: "अभी वापस लाएं?",
            restoreNow: "अभी वापस लाएं",
            later: "बाद में",
            fatalTitle: "डेस्कटॉप क्लीनर शुरू नहीं हो सका",
            menuClean: "डेस्कटॉप साफ करें",
            menuRestore: "डेस्कटॉप वापस लाएं",
            menuLanguage: "भाषा",
            menuFollowSystem: "सिस्टम भाषा इस्तेमाल करें",
            menuQuit: "डेस्कटॉप क्लीनर बंद करें",
            permissionFootnote: "Finder नियंत्रण की अनुमति दें",
            manyIconsWarning: "डेस्कटॉप पर कई आइटम हैं; खींचते समय कुछ आइटम साथ चलेंगे और छोड़ने पर सब सिंक होंगे।",
            tooManyIconsWarning: "डेस्कटॉप पर 300 से ज़्यादा आइटम हैं; खींचते समय लाइव अपडेट रुकेगा और छोड़ने पर सब सिंक होंगे।"
        )
    ]
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
