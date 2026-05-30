/**
 * [INPUT]: 依赖 DesktopItem、RecoveryState、WindowFrame 和 ScreenFrame 计算桌面图标吸附坐标。
 * [OUTPUT]: 对外提供 LayoutEngine.attach(items:to:)、moves(for:windowFrame:)、restoreMoves(for:)。
 * [POS]: DeskMagnetCore 的纯布局层，把 Finder 图标锚点压进窗口内部安全区，由桌面层承担 Z 轴遮盖。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

public struct LayoutEngine: Sendable {
    public enum Jitter: Sendable {
        case none
        case deterministic
    }

    private let iconStep: Int
    private let hiddenInsetX: Int
    private let hiddenInsetTop: Int
    private let hiddenInsetBottom: Int
    private let jitter: Jitter
    private let screens: [ScreenFrame]
    private let iconSize = 48

    private struct Projection: Sendable {
        let minX: Int
        let maxX: Int
        let minY: Int
        let maxY: Int
    }

    public init(
        iconStep: Int = 88,
        hiddenInsetX: Int = 144,
        hiddenInsetTop: Int = 112,
        hiddenInsetBottom: Int = 96,
        jitter: Jitter = .deterministic,
        screens: [ScreenFrame] = []
    ) {
        self.iconStep = iconStep
        self.hiddenInsetX = hiddenInsetX
        self.hiddenInsetTop = hiddenInsetTop
        self.hiddenInsetBottom = hiddenInsetBottom
        self.jitter = jitter
        self.screens = screens
    }

    public func attach(items: [DesktopItem], to frame: WindowFrame) -> [RecoveryItem] {
        items.enumerated().map { index, item in
            let attached = point(for: index, frame: frame)
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
        state.items.enumerated().map { index, item in
            IconMove(name: item.name, position: point(for: index, frame: windowFrame))
        }
    }

    public func restoreMoves(for state: RecoveryState) -> [IconMove] {
        state.items.map { IconMove(name: $0.name, position: $0.originalPosition) }
    }

    private func point(for index: Int, frame: WindowFrame) -> Point {
        let projection = projection(for: frame)
        let columnCount = max(1, slots(from: projection.minX, through: projection.maxX))
        let rowCount = max(1, slots(from: projection.minY, through: projection.maxY))
        let column = index % columnCount
        let row = (index / columnCount) % rowCount
        let gridPoint = Point(x: projection.minX + column * iconStep, y: projection.minY + row * iconStep)
        return scattered(gridPoint, index: index, projection: projection)
    }

    private func slots(from minimum: Int, through maximum: Int) -> Int {
        guard maximum >= minimum else { return 0 }
        return (maximum - minimum) / iconStep + 1
    }

    private func projection(for frame: WindowFrame) -> Projection {
        let minX = frame.x + hiddenInsetX
        let maxX = frame.x + frame.width - iconSize - hiddenInsetX
        let minY = frame.y + hiddenInsetTop
        let maxY = frame.y + frame.height - iconSize - hiddenInsetBottom
        guard let screen = activeScreen(for: frame) else {
            return normalizedProjection(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
        }
        return normalizedProjection(
            minX: max(screen.x, minX),
            maxX: min(screen.maxX - iconSize, maxX),
            minY: max(screen.y, minY),
            maxY: min(screen.maxY - iconSize, maxY)
        )
    }

    private func normalizedProjection(minX: Int, maxX: Int, minY: Int, maxY: Int) -> Projection {
        Projection(
            minX: minX,
            maxX: max(minX, maxX),
            minY: minY,
            maxY: max(minY, maxY)
        )
    }

    private func scattered(_ point: Point, index: Int, projection: Projection) -> Point {
        guard case .deterministic = jitter else { return point }
        let spanX = projection.maxX - projection.minX
        let spanY = projection.maxY - projection.minY
        let candidate = Point(
            x: projection.minX + scatteredOffset(seed: index, salt: 17, span: spanX),
            y: projection.minY + scatteredOffset(seed: index, salt: 31, span: spanY)
        )
        guard candidate != point else {
            return Point(
                x: projection.minX + scatteredOffset(seed: index + 1, salt: 17, span: spanX),
                y: projection.minY + scatteredOffset(seed: index + 1, salt: 31, span: spanY)
            )
        }
        return candidate
    }

    private func scatteredOffset(seed: Int, salt: Int, span: Int) -> Int {
        guard span > 0 else { return 0 }
        let value = (seed + 1) * 1103515245 &+ salt * 12345
        return abs(value) % (span + 1)
    }

    private func activeScreen(for frame: WindowFrame) -> ScreenFrame? {
        guard !screens.isEmpty else { return nil }
        let centerX = frame.x + frame.width / 2
        let centerY = frame.y + frame.height / 2
        return screens.first { $0.contains(x: centerX, y: centerY) } ?? screens.first
    }
}
