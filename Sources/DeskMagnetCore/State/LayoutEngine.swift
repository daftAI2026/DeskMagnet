/**
 * [INPUT]: 依赖 DesktopItem、RecoveryState、WindowFrame 和 ScreenFrame 计算桌面图标吸附坐标。
 * [OUTPUT]: 对外提供 LayoutEngine.attach(items:to:)、moves(for:windowFrame:)、restoreMoves(for:)。
 * [POS]: DeskMagnetCore 的纯布局层，按窗口外安全区域选择 Finder 图标锚点。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

public struct LayoutEngine: Sendable {
    public enum Jitter: Sendable {
        case none
        case deterministic
    }

    private let iconStep: Int
    private let leading: Int
    private let iconAnchorClearance: Int
    private let columns: Int
    private let jitter: Jitter
    private let screens: [ScreenFrame]
    private let iconSize = 48

    private enum Zone: Sendable {
        case below
        case right
        case left
        case above
    }

    public init(
        iconStep: Int = 88,
        leading: Int = 20,
        iconAnchorClearance: Int = 72,
        columns: Int = 4,
        jitter: Jitter = .deterministic,
        screens: [ScreenFrame] = []
    ) {
        self.iconStep = iconStep
        self.leading = leading
        self.iconAnchorClearance = iconAnchorClearance
        self.columns = columns
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
        guard let screen = activeScreen(for: frame) else {
            let offset = offset(for: index, frame: frame)
            return Point(x: frame.x + offset.dx, y: frame.y + offset.dy)
        }
        return zonedPoint(for: index, frame: frame, screen: screen) ?? screen.clamped(
            Point(x: screen.x + leading, y: screen.y + leading),
            iconSize: iconSize
        )
    }

    private func zonedPoint(for index: Int, frame: WindowFrame, screen: ScreenFrame) -> Point? {
        var remainder = index
        for zone in [Zone.below, .right, .left, .above] {
            let capacity = self.capacity(of: zone, frame: frame, screen: screen)
            guard capacity > 0 else { continue }
            if remainder < capacity {
                let point = point(in: zone, at: remainder, frame: frame, screen: screen)
                return jittered(point, index: index, frame: frame, screen: screen)
            }
            remainder -= capacity
        }
        return nil
    }

    private func offset(for index: Int, frame: WindowFrame) -> Offset {
        let columnCount = columns(for: frame)
        let column = index % columnCount
        let row = index / columnCount
        let stagger = row.isMultiple(of: 2) ? 0 : iconStep / 2
        let jitter = jitterOffset(for: index)
        return Offset(
            dx: leading + stagger + column * iconStep + jitter.dx,
            dy: frame.height + iconAnchorClearance + row * iconStep + jitter.dy
        )
    }

    private func columns(for frame: WindowFrame) -> Int {
        max(columns, max(1, (frame.width - leading) / iconStep))
    }

    private func capacity(of zone: Zone, frame: WindowFrame, screen: ScreenFrame) -> Int {
        switch zone {
        case .below:
            return slots(from: belowMinX(frame, screen), through: belowMaxX(frame, screen))
                * slots(from: belowMinY(frame), through: screen.maxY - iconSize)
        case .right:
            return slots(from: rightMinX(frame), through: screen.maxX - iconSize)
                * slots(from: sideMinY(frame, screen), through: sideMaxY(frame, screen))
        case .left:
            return slots(from: screen.x, through: leftMaxX(frame))
                * slots(from: sideMinY(frame, screen), through: sideMaxY(frame, screen))
        case .above:
            return slots(from: belowMinX(frame, screen), through: belowMaxX(frame, screen))
                * slots(from: screen.y, through: aboveMaxY(frame))
        }
    }

    private func point(in zone: Zone, at ordinal: Int, frame: WindowFrame, screen: ScreenFrame) -> Point {
        switch zone {
        case .below:
            return horizontalPoint(ordinal, x: belowMinX(frame, screen), y: belowMinY(frame), maxX: belowMaxX(frame, screen))
        case .right:
            return verticalPoint(ordinal, x: rightMinX(frame), y: sideMinY(frame, screen), maxY: sideMaxY(frame, screen))
        case .left:
            return verticalPoint(ordinal, x: leftMaxX(frame), y: sideMinY(frame, screen), maxY: sideMaxY(frame, screen), direction: -1)
        case .above:
            return horizontalPoint(ordinal, x: belowMinX(frame, screen), y: aboveMaxY(frame), maxX: belowMaxX(frame, screen), direction: -1)
        }
    }

    private func horizontalPoint(_ ordinal: Int, x: Int, y: Int, maxX: Int, direction: Int = 1) -> Point {
        let columnCount = max(1, slots(from: x, through: maxX))
        let column = ordinal % columnCount
        let row = ordinal / columnCount
        return Point(x: x + column * iconStep, y: y + direction * row * iconStep)
    }

    private func verticalPoint(_ ordinal: Int, x: Int, y: Int, maxY: Int, direction: Int = 1) -> Point {
        let rowCount = max(1, slots(from: y, through: maxY))
        let row = ordinal % rowCount
        let column = ordinal / rowCount
        return Point(x: x + direction * column * iconStep, y: y + row * iconStep)
    }

    private func slots(from minimum: Int, through maximum: Int) -> Int {
        guard maximum >= minimum else { return 0 }
        return (maximum - minimum) / iconStep + 1
    }

    private func belowMinX(_ frame: WindowFrame, _ screen: ScreenFrame) -> Int {
        max(screen.x, frame.x + leading)
    }

    private func belowMaxX(_ frame: WindowFrame, _ screen: ScreenFrame) -> Int {
        min(screen.maxX - iconSize, frame.x + frame.width - iconSize)
    }

    private func belowMinY(_ frame: WindowFrame) -> Int {
        frame.y + frame.height + iconAnchorClearance
    }

    private func rightMinX(_ frame: WindowFrame) -> Int {
        frame.x + frame.width + iconAnchorClearance
    }

    private func leftMaxX(_ frame: WindowFrame) -> Int {
        frame.x - iconAnchorClearance - iconSize
    }

    private func sideMinY(_ frame: WindowFrame, _ screen: ScreenFrame) -> Int {
        max(screen.y, frame.y + leading)
    }

    private func sideMaxY(_ frame: WindowFrame, _ screen: ScreenFrame) -> Int {
        min(screen.maxY - iconSize, frame.y + frame.height - iconSize)
    }

    private func aboveMaxY(_ frame: WindowFrame) -> Int {
        frame.y - iconAnchorClearance - iconSize
    }

    private func jittered(_ point: Point, index: Int, frame: WindowFrame, screen: ScreenFrame) -> Point {
        let jitter = jitterOffset(for: index)
        let candidate = Point(x: point.x + jitter.dx, y: point.y + jitter.dy)
        guard containsAnchor(candidate, in: screen), isOutsideWindow(candidate, frame: frame) else {
            return point
        }
        return candidate
    }

    private func containsAnchor(_ point: Point, in screen: ScreenFrame) -> Bool {
        point.x >= screen.x && point.x <= screen.maxX - iconSize
            && point.y >= screen.y && point.y <= screen.maxY - iconSize
    }

    private func isOutsideWindow(_ point: Point, frame: WindowFrame) -> Bool {
        point.x <= frame.x - iconAnchorClearance - iconSize
            || point.x >= frame.x + frame.width + iconAnchorClearance
            || point.y <= frame.y - iconAnchorClearance - iconSize
            || point.y >= frame.y + frame.height + iconAnchorClearance
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
