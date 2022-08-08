import CoreGraphics

extension CGPoint {
    func nearBottomRightCorner(of rect: CGRect) -> Bool {
        let threshold = A11yControl.Config().resizeMarkerSize
        return abs(x - rect.bottomCorner.x) < threshold
            && abs(y - rect.bottomCorner.y) < threshold
    }
}

extension CGRect {
    var bottomCorner: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
}
