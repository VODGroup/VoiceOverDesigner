import QuartzCore

extension CGRect {
    func increase(to minimalSize: CGSize) -> Self {
        var rect = self
        
        if size.width < minimalSize.width {
            rect = rect.insetBy(dx: (size.width - minimalSize.width)/2, dy: 0)
        }
        
        if size.height < minimalSize.height {
            rect = rect.insetBy(dx: 0, dy: (size.height - minimalSize.height)/2)
        }
        
        return rect
    }
}

extension CGPoint {
    var isSmallOffset: Bool {
        if abs(x) < 2 && abs(y) < 2 {
            return true
        }
        
        return false
    }
}

extension CGPoint {
    static func -(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x - rhs.x,
             y: lhs.y - rhs.y)
    }
}
