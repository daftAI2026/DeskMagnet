/**
 * [INPUT]: 依赖 DesktopItem、RecoveryState、WindowFrame 计算桌面图标吸附坐标。
 * [OUTPUT]: 对外提供 LayoutEngine.attach(items:to:)、moves(for:windowFrame:)、restoreMoves(for:)。
 * [POS]: DeskMagnetCore 的纯布局层，被 AppCoordinator 和窗口跟随逻辑复用。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

public struct LayoutEngine: Sendable {
    private let iconStep: Int
    private let leading: Int
    private let belowWindow: Int
    private let columns: Int

    public init(iconStep: Int = 88, leading: Int = 20, belowWindow: Int = 24, columns: Int = 4) {
        self.iconStep = iconStep
        self.leading = leading
        self.belowWindow = belowWindow
        self.columns = columns
    }

    public func attach(items: [DesktopItem], to frame: WindowFrame) -> [RecoveryItem] {
        items.enumerated().map { index, item in
            let offset = offset(for: index, frame: frame)
            let attached = Point(x: frame.x + offset.dx, y: frame.y + offset.dy)
            return RecoveryItem(
                name: item.name,
                path: item.path,
                originalPosition: item.position,
                attachedOffset: offset,
                lastKnownPosition: attached
            )
        }
    }

    public func moves(for state: RecoveryState, windowFrame: WindowFrame) -> [IconMove] {
        state.items.map { item in
            IconMove(
                name: item.name,
                position: Point(
                    x: windowFrame.x + item.attachedOffset.dx,
                    y: windowFrame.y + item.attachedOffset.dy
                )
            )
        }
    }

    public func restoreMoves(for state: RecoveryState) -> [IconMove] {
        state.items.map { IconMove(name: $0.name, position: $0.originalPosition) }
    }

    private func offset(for index: Int, frame: WindowFrame) -> Offset {
        let column = index % columns
        let row = index / columns
        return Offset(dx: leading + column * iconStep, dy: frame.height + belowWindow + row * iconStep)
    }
}
