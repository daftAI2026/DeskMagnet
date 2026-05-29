/**
 * [INPUT]: 依赖 DesktopItem、RecoveryState、WindowFrame 计算桌面图标吸附坐标。
 * [OUTPUT]: 对外提供 LayoutEngine.attach(items:to:)、moves(for:windowFrame:)、restoreMoves(for:)。
 * [POS]: DeskMagnetCore 的纯布局层，被 AppCoordinator 和窗口跟随逻辑复用。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

public struct LayoutEngine: Sendable {
    public enum Jitter: Sendable {
        case none
        case deterministic
    }

    private let iconStep: Int
    private let leading: Int
    private let belowWindow: Int
    private let columns: Int
    private let jitter: Jitter
    private let screens: [ScreenFrame]

    public init(
        iconStep: Int = 88,
        leading: Int = 20,
        belowWindow: Int = 24,
        columns: Int = 4,
        jitter: Jitter = .deterministic,
        screens: [ScreenFrame] = []
    ) {
        self.iconStep = iconStep
        self.leading = leading
        self.belowWindow = belowWindow
        self.columns = columns
        self.jitter = jitter
        self.screens = screens
    }

    public func attach(items: [DesktopItem], to frame: WindowFrame) -> [RecoveryItem] {
        items.enumerated().map { index, item in
            let offset = offset(for: index, frame: frame)
            let unclamped = Point(x: frame.x + offset.dx, y: frame.y + offset.dy)
            let attached = activeScreen(for: frame)?.clamped(unclamped) ?? unclamped
            let finalOffset = Offset(dx: attached.x - frame.x, dy: attached.y - frame.y)
            return RecoveryItem(
                name: item.name,
                path: item.path,
                originalPosition: item.position,
                attachedOffset: finalOffset,
                lastKnownPosition: attached
            )
        }
    }

    public func moves(for state: RecoveryState, windowFrame: WindowFrame) -> [IconMove] {
        state.items.map { item in
            let point = Point(
                x: windowFrame.x + item.attachedOffset.dx,
                y: windowFrame.y + item.attachedOffset.dy
            )
            return IconMove(name: item.name, position: activeScreen(for: windowFrame)?.clamped(point) ?? point)
        }
    }

    public func restoreMoves(for state: RecoveryState) -> [IconMove] {
        state.items.map { IconMove(name: $0.name, position: $0.originalPosition) }
    }

    private func offset(for index: Int, frame: WindowFrame) -> Offset {
        let column = index % columns
        let row = index / columns
        let stagger = row.isMultiple(of: 2) ? 0 : iconStep / 2
        let jitter = jitterOffset(for: index)
        return Offset(
            dx: leading + stagger + column * iconStep + jitter.dx,
            dy: frame.height + belowWindow + row * iconStep + jitter.dy
        )
    }

    private func jitterOffset(for index: Int) -> Offset {
        guard case .deterministic = jitter else { return Offset(dx: 0, dy: 0) }
        let seed = (index + 1) * 1103515245 &+ 12345
        let dx = seed % 17 - 8
        let dy = (seed / 17) % 13 - 6
        return Offset(dx: dx, dy: dy)
    }

    private func activeScreen(for frame: WindowFrame) -> ScreenFrame? {
        guard !screens.isEmpty else { return nil }
        let centerX = frame.x + frame.width / 2
        let centerY = frame.y + frame.height / 2
        return screens.first { $0.contains(x: centerX, y: centerY) } ?? screens.first
    }
}
