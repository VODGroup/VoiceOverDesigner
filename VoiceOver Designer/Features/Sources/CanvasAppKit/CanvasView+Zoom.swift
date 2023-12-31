import Canvas
import AppKit

extension CanvasView {
    
    // Scroll wheel function is implemented at CanvasScrollView
    
    public override func magnify(with event: NSEvent) {
        // TODO: This forwarding is strange.
        // Looks like scrollView should be firstResponder automatically
        scrollView.magnify(with: event)
    }
    
    public override func smartMagnify(with event: NSEvent) {
        let artboardCoordinateTouch = event.location(in: contentView)
        
        let frame = contentView.frames.first { frameLayer in
            frameLayer.frame.contains(artboardCoordinateTouch)
        }
        
        guard let frame else {
            fitToWindow(animated: true)
            return
        }
        
        guard !isNear(toFit: frame.frame) else {
            fitToWindow(animated: true)
            return
        }
        
        fit(to: frame.frame,
            animated: true)
    }
}

extension CanvasView: CanvasScrollViewProtocol {
    
    func fitToWindow(animated: Bool) {
        let contentBounds = contentView.boundingBox
        
        fit(to: contentBounds, animated: animated)
    }
    
    func isNear(toFit bounds: CGRect) -> Bool {
        let fittingMagnification = fittingMagnification(bounds: bounds)
        
        let isNear = abs(scrollView.magnification - fittingMagnification) < 0.1
        return isNear
    }
    
    func fit(to bounds: CGRect, animated: Bool) {
        scrollView.animator().magnify(toFit: bounds)
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
        // Manually trim to keep value to sync with hud
        let newLevel = (scrollView.minMagnification...scrollView.maxMagnification).trim(magnification)
        
        let scrollView = animated ? scrollView.animator() : scrollView

        dragnDropView.scale = newLevel
        
        let center = center
        ?? contentView.hud.selectedControlFrame?.center
        ?? contentView.frame.center
        
        scrollView?.setMagnification(
            magnification,
            centeredAt: center)
    }
    
    private var isImageMagnificationFitsToWindow: Bool {
        abs(fittingMagnification - scrollView.magnification) < 0.01
    }
    
    private var fittingMagnification: CGFloat {
        let contentBounds = contentView.boundingBox

        return fittingMagnification(bounds: contentBounds)
    }
    
    private func fittingMagnification(bounds: CGRect) -> CGFloat {
        let fittingMagnification = (scrollView.frame.size
                                    / bounds.size).min()
        
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
