import CoreGraphics

extension CGPoint {
    func nearBottomRightCorner(of rect: CGRect) -> Bool {
        let threeshold = A11yControl.Config().resizeMarkerSize
        return abs(x - rect.bottomCorner.x) < threeshold
            && abs(y - rect.bottomCorner.y) < threeshold
    }
}

extension CGRect {
    var bottomCorner: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
}
