import UIKit

public protocol ScrollViewConverable {
    func frameInScreenCoordinates(_ frame: CGRect) -> CGRect
    var zoomScale: CGFloat { get }
}

public extension ScrollViewConverable {
    func scaledFrame(_ frame: CGRect) -> CGRect {
        let scale = CGAffineTransform(scaleX: zoomScale, y: zoomScale)
        
        return CGRectApplyAffineTransform(frame, scale)
    }
}

extension UIScrollView: ScrollViewConverable {
    public func frameInScreenCoordinates(_ frame: CGRect) -> CGRect {
        let new = scaledFrame(frame)
        let rect = UIAccessibility.convertToScreenCoordinates(new, in: self)

        return rect
    }
}

extension CGRect {
    func relative(to rect: CGRect) -> CGRect {
        
        let origin = CGPoint(
            x: minX - rect.minX,
            y: minY - rect.minY)
        
        return CGRect(
            origin: origin,
            size: size)
    }
    
    func withZeroOrigin() -> CGRect {
        CGRect(origin: .zero, size: size)
    }
}

