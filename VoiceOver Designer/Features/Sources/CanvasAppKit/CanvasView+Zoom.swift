import Canvas
import AppKit

extension CanvasView: CanvasScrollViewProtocol {
    func fitToWindow(animated: Bool) {
        let contentBounds = contentView.boundingBox
        
        let fittingMagnification = fittingMagnification // Calculate once
        
        let originOffsetToCenter = (contentBounds.size - scrollView.frame.size / fittingMagnification) / 2
        
        let center = contentBounds.origin + originOffsetToCenter.point()
        
        scrollView.contentView.scroll(to: center)
        
        setMagnification(to: fittingMagnification,
                         center: center,
                         animated: animated)
    }
    
    func fitToWindowIfAlreadyFitted() {
        if isImageMagnificationFitsToWindow {
            fitToWindow(animated: false)
        }
    }
    
    func changeMagnification(_ change: (_ current: CGFloat) -> CGFloat) {
        let current = scrollView.magnification
        let changed = change(current)
        setMagnification(to: changed, animated: false)
    }
    
    private func setMagnification(
        to magnification: CGFloat,
        center: CGPoint? = nil,
        animated: Bool
    ) {
        // Manually trim to keep value in sync with real limitation
        let newLevel = (scrollView.minMagnification...scrollView.maxMagnification).trim(magnification)
        
        var scrollView = self.scrollView
        if animated {
            scrollView = self.scrollView.animator()
            
            self.scrollView.updateHud(to: newLevel) // Animator calls another function
        }
        
        dragnDropView.scale = newLevel
        
        let center = center
        ?? contentView.hud.selectedControlFrame?.center
        ?? contentView.frame.center
        
        scrollView?.setMagnification(
            newLevel,
            centeredAt: center)
    }
    
    private var isImageMagnificationFitsToWindow: Bool {
        abs(fittingMagnification - scrollView.magnification) < 0.01
    }
    
    private var fittingMagnification: CGFloat {
        let contentBounds = contentView.boundingBox

        let fittingMagnification = (scrollView.frame.size
                                    / contentBounds.size).min()
        
        let limited = (scrollView.minMagnification...scrollView.maxMagnification).trim(fittingMagnification)
        
        return limited
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

extension ClosedRange where Bound == CGFloat {
    fileprivate func trim(_ value: Bound) -> Bound {
        Swift.max(
            lowerBound,
            Swift.min(upperBound, value)
        )
    }
}
