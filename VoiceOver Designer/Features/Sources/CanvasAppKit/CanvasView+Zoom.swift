import Canvas
import AppKit

extension CanvasView {
    
    public override func magnify(with event: NSEvent) {
        scrollView.magnify(with: event)
    }
    
    public override func smartMagnify(with event: NSEvent) {
        scrollView.smartMagnify(with: event)
    }
}

extension CGSize {
    static func /(_ lhs: Self, _ divider: CGFloat) -> Self {
        precondition(divider != 0, "Can't divide by zero")
        
        return Self(width: lhs.width/divider,
                    height: lhs.height/divider)
    }
    
    static func -(_ lhs: Self, _ rhs: Self) -> Self {
        Self(width: lhs.width - rhs.width,
             height: lhs.height - rhs.height)
    }
    
    static func /(_ lhs: Self, _ rhs: Self) -> Self {
        precondition(rhs.width != 0, "Can't divide by zero X")
        precondition(rhs.height != 0, "Can't divide by zero Y")
        
        return Self(width:  lhs.width/rhs.width,
                    height: lhs.height/rhs.height)
    }
    
    func point() -> CGPoint {
        CGPoint(x: width, y: height)
    }
    
    
    func min() -> CGFloat {
        Swift.min(width, height)
    }
}

extension CGPoint {
    
    static func +(_ lhs: Self, _ rhs: Self) -> Self {
        Self(x:  lhs.x + rhs.x,
             y: lhs.y + rhs.y)
    }
    
    func min() -> CGFloat {
        Swift.min(x, y)
    }
}

