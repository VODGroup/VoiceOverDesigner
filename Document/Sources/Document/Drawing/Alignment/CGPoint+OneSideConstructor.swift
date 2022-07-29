import QuartzCore

public extension CGPoint {
    static func coord(_ coord: CGFloat) -> Self {
        CGPoint(x: coord, y: coord)
    }
}

public extension CGSize {
    static func side(_ side: CGFloat) -> Self {
        CGSize(width: side, height: side)
    }
}
