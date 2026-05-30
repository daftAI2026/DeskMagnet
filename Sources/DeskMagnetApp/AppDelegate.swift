/**
 * [INPUT]: 依赖 AppKit/SwiftUI/Combine 创建 NSWindow 和主菜单，依赖 DeskMagnetCore.AppCoordinator 恢复未完成状态。
 * [OUTPUT]: 提供 AppDelegate，管理固定尺寸亮色主窗口、顶层应用/清理/语言菜单、启动居中、清理后焦点恢复、关闭自动恢复、启动恢复提示。
 * [POS]: DeskMagnetApp 的生命周期控制器，连接 macOS 窗口事件与 DeskMagnetViewModel。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import AppKit
import Combine
import DeskMagnetCore
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var window: NSWindow?
    private var viewModel: DeskMagnetViewModel?
    private var followController: WindowFollowController?
    private let languageStore = AppLanguageStore()
    private var cancellables: Set<AnyCancellable> = []
    private weak var appMenuItem: NSMenuItem?
    private weak var appMenu: NSMenu?
    private weak var cleanRootMenuItem: NSMenuItem?
    private weak var cleanMenuItem: NSMenuItem?
    private weak var restoreMenuItem: NSMenuItem?
    private weak var languageRootMenuItem: NSMenuItem?
    private weak var systemLanguageMenuItem: NSMenuItem?
    private weak var quitMenuItem: NSMenuItem?
    private var languageMenuItems: [AppLanguage: NSMenuItem] = [:]
    private var closingAfterRestore = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.appearance = NSAppearance(named: .aqua)
        do {
            let store = try RecoveryStore.live()
            let converter = NSScreen.deskMagnetCoordinateConverter
            let coordinator = AppCoordinator(store: store, layout: LayoutEngine(screens: NSScreen.deskMagnetScreens(converter: converter)))
            let model = DeskMagnetViewModel(coordinator: coordinator, languageStore: languageStore)
            let content = ContentView(viewModel: model, languageStore: languageStore)
            let windowSize = NSSize(width: 800, height: 520)
            let window = NSWindow(
                contentRect: NSRect(origin: .zero, size: windowSize),
                styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.title = languageStore.strings.appName
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.minSize = windowSize
            window.maxSize = windowSize
            window.isRestorable = false
            window.appearance = NSAppearance(named: .aqua)
            window.backgroundColor = .controlBackgroundColor
            window.contentView = NSHostingView(rootView: content)
            window.deskMagnetCenterOnMainScreen()
            window.delegate = self
            model.windowFrameProvider = { [weak window] in window?.deskMagnetFrame(converter: converter) }
            model.focusRestorer = { [weak window] in
                window?.makeKeyAndOrderFront(nil)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
            self.window = window
            self.viewModel = model
            configureMainMenu()
            bindMenuState(to: model)
            self.followController = WindowFollowController(window: window, converter: converter) { [weak model] frame, isFinal in
                Task { @MainActor in
                    await model?.sync(windowFrame: frame, final: isFinal)
                }
            } throttleMilliseconds: { [weak model] in
                model?.followThrottleMilliseconds ?? 120
            }
            window.makeKeyAndOrderFront(nil)
            promptForUnfinishedStateIfNeeded(model: model)
        } catch {
            showFatalError(error)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let viewModel, viewModel.isAttached else { return .terminateNow }
        guard !closingAfterRestore else { return .terminateLater }
        closingAfterRestore = true
        Task { @MainActor in
            let restored = await viewModel.restoreForTermination()
            closingAfterRestore = false
            sender.reply(toApplicationShouldTerminate: restored)
        }
        return .terminateLater
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard let viewModel, viewModel.isAttached else { return true }
        guard !closingAfterRestore else { return false }
        closingAfterRestore = true
        Task { @MainActor in
            let restored = await viewModel.restoreForTermination()
            closingAfterRestore = false
            if restored {
                NSApplication.shared.terminate(nil)
            }
        }
        return false
    }

    private func promptForUnfinishedStateIfNeeded(model: DeskMagnetViewModel) {
        guard model.hasUnfinishedState else { return }
        let alert = NSAlert()
        alert.messageText = languageStore.strings.unfinishedTitle
        alert.informativeText = languageStore.strings.unfinishedMessage
        alert.addButton(withTitle: languageStore.strings.restoreNow)
        alert.addButton(withTitle: languageStore.strings.later)
        if alert.runModal() == .alertFirstButtonReturn {
            Task { @MainActor in await model.restore() }
        }
    }

    private func showFatalError(_ error: Error) {
        let alert = NSAlert(error: error)
        alert.messageText = languageStore.strings.fatalTitle
        alert.runModal()
        NSApplication.shared.terminate(nil)
    }

    private func configureMainMenu() {
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu(title: "")
        let cleanRootMenuItem = NSMenuItem()
        let cleanMenu = NSMenu(title: "")
        let cleanMenuItem = NSMenuItem(title: "", action: #selector(cleanFromMenu), keyEquivalent: "k")
        let restoreMenuItem = NSMenuItem(title: "", action: #selector(restoreFromMenu), keyEquivalent: "r")
        let languageRootMenuItem = NSMenuItem()
        let languageMenu = NSMenu(title: "")
        let systemLanguageMenuItem = NSMenuItem(title: "", action: #selector(selectSystemLanguageFromMenu), keyEquivalent: "")
        let quitMenuItem = NSMenuItem(title: "", action: #selector(quitFromMenu), keyEquivalent: "q")

        mainMenu.addItem(appMenuItem)
        mainMenu.addItem(cleanRootMenuItem)
        mainMenu.addItem(languageRootMenuItem)
        appMenuItem.submenu = appMenu
        cleanRootMenuItem.submenu = cleanMenu
        languageRootMenuItem.submenu = languageMenu

        cleanMenuItem.target = self
        restoreMenuItem.target = self
        systemLanguageMenuItem.target = self
        quitMenuItem.target = self

        languageMenu.addItem(systemLanguageMenuItem)
        languageMenu.addItem(.separator())
        languageMenuItems = AppLanguage.allCases.reduce(into: [:]) { items, language in
            let item = NSMenuItem(title: language.nativeName, action: #selector(selectLanguageFromMenu(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = language.rawValue
            languageMenu.addItem(item)
            items[language] = item
        }
        appMenu.addItem(restoreMenuItem)
        appMenu.addItem(.separator())
        appMenu.addItem(quitMenuItem)
        cleanMenu.addItem(cleanMenuItem)

        NSApplication.shared.mainMenu = mainMenu
        self.appMenuItem = appMenuItem
        self.appMenu = appMenu
        self.cleanRootMenuItem = cleanRootMenuItem
        self.cleanMenuItem = cleanMenuItem
        self.restoreMenuItem = restoreMenuItem
        self.languageRootMenuItem = languageRootMenuItem
        self.systemLanguageMenuItem = systemLanguageMenuItem
        self.quitMenuItem = quitMenuItem
        updateMenu()
    }

    private func bindMenuState(to model: DeskMagnetViewModel) {
        model.$phase
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateMenu() }
            .store(in: &cancellables)

        languageStore.$selectedLanguage
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.window?.title = self?.languageStore.strings.appName ?? ""
                self?.updateMenu()
            }
            .store(in: &cancellables)
    }

    private func updateMenu() {
        let strings = languageStore.strings
        appMenuItem?.title = strings.appName
        appMenu?.title = strings.appName
        cleanRootMenuItem?.title = strings.menuClean
        cleanMenuItem?.title = strings.menuClean
        restoreMenuItem?.title = strings.menuRestore
        languageRootMenuItem?.title = strings.menuLanguage
        systemLanguageMenuItem?.title = strings.menuFollowSystem
        quitMenuItem?.title = strings.menuQuit
        cleanMenuItem?.isEnabled = viewModel?.canClean ?? false
        restoreMenuItem?.isEnabled = viewModel?.canRestore ?? false
        systemLanguageMenuItem?.state = languageStore.selectedLanguage == nil ? .on : .off
        for language in AppLanguage.allCases {
            languageMenuItems[language]?.state = languageStore.selectedLanguage == language ? .on : .off
        }
    }

    @objc private func cleanFromMenu() {
        viewModel?.primaryAction()
    }

    @objc private func restoreFromMenu() {
        guard let viewModel else { return }
        Task { @MainActor in await viewModel.restore() }
    }

    @objc private func selectSystemLanguageFromMenu() {
        languageStore.select(nil)
    }

    @objc private func selectLanguageFromMenu(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let language = AppLanguage(rawValue: rawValue)
        else { return }
        languageStore.select(language)
    }

    @objc private func quitFromMenu() {
        NSApplication.shared.terminate(nil)
    }
}

private extension NSWindow {
    func deskMagnetCenterOnMainScreen() {
        let visibleFrame = NSScreen.main?.visibleFrame ?? NSScreen.screens.first?.visibleFrame ?? frame
        setFrameOrigin(
            NSPoint(
                x: visibleFrame.midX - frame.width / 2,
                y: visibleFrame.midY - frame.height / 2
            )
        )
    }

    func deskMagnetFrame(converter: DesktopCoordinateConverter) -> WindowFrame {
        converter.windowFrameFromAppKit(
            x: Int(frame.origin.x.rounded()),
            y: Int(frame.origin.y.rounded()),
            width: Int(frame.size.width.rounded()),
            height: Int(frame.size.height.rounded())
        )
    }
}

private extension NSScreen {
    static var deskMagnetCoordinateConverter: DesktopCoordinateConverter {
        DesktopCoordinateConverter(globalMaxY: Int(screens.map(\.frame.maxY).max()?.rounded() ?? 0))
    }

    static func deskMagnetScreens(converter: DesktopCoordinateConverter) -> [ScreenFrame] {
        screens.map {
            converter.screenFrameFromAppKit(
                x: Int($0.frame.origin.x.rounded()),
                y: Int($0.frame.origin.y.rounded()),
                width: Int($0.frame.size.width.rounded()),
                height: Int($0.frame.size.height.rounded())
            )
        }
    }
}
