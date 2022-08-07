import CoreGraphics

extension CGPoint {
    func nearBottomRightCorner(of rect: CGRect) -> Bool {
        abs(x - rect.bottomCorner.x) < 5 &&
        abs(y - rect.bottomCorner.y) < 5
    }
}

extension CGRect {
    var bottomCorner: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
}
