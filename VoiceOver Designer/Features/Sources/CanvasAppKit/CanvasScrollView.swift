import AppKit
import CommonUI
import Canvas

protocol ScrollViewZoomDelegate: AnyObject {
    func didUpdateScale(_ magnification: CGFloat)
}

class CanvasScrollView: NSScrollView {
    
    weak var delegate: ScrollViewZoomDelegate?
    
    func documentView() -> ContentView {
        documentView! as! ContentView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        verticalScrollElasticity = .none
        horizontalScrollElasticity = .none
        
        documentView().wantsLayer = true
        documentView().addHUD()
    }
    
    // MARK: - Zoom actions
    
    // Touch pad zooming is implemented at CanvasView
    
    public override func scrollWheel(with event: NSEvent) {
        let isCommandPressed = event.modifierFlags.contains(.command)
        
        let isTrackpad = !event.hasPreciseScrollingDeltas
        let canScroll = isTrackpad || isCommandPressed // Command changes mouse behaviour from pan to scroll
        
        guard canScroll else {
            super.scrollWheel(with: event)
            return
        }
        
        let dy = event.deltaY
        if dy != 0.0 {
            let magnification = magnification + dy/30
            let cursorLocation = contentView.convert(event.locationInWindow, from: nil)
            
            setMagnification(magnification, centeredAt: cursorLocation)
        }
    }
    
    public override func smartMagnify(with event: NSEvent) {
        let artboardCoordinateTouch = event.location(in: documentView())
        
        let frame = documentView().frames.first { frameLayer in
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
    
    // MARK: Delegates
    
    // Update after any change of position or magnification
    override func reflectScrolledClipView(_ cView: NSClipView) {
        super.reflectScrolledClipView(cView)
        
        delegate?.didUpdateScale(magnification)
    }
    
    // MARK: Custom zooming
    func fittingMagnification(bounds: CGRect) -> CGFloat {
        let fittingMagnification = (frame.size / bounds.size).min()
        
        let limited = (minMagnification...maxMagnification).trim(fittingMagnification)
        
        return limited
    }
    
    private var fittingMagnification: CGFloat {
        let contentBounds = documentView().boundingBox
        
        return fittingMagnification(bounds: contentBounds)
    }
    
    func fitToWindowIfAlreadyFitted() {
        if imageMagnificationFitsToWindow {
            fitToWindow(animated: false)
        }
    }
    
    func fitToWindow(animated: Bool) {
        let contentBounds = documentView().boundingBox
        
        fit(to: contentBounds, animated: animated)
    }
    
    func changeMagnification(_ change: (_ current: CGFloat) -> CGFloat) {
        let changed = change(magnification)
        setMagnification(to: changed, animated: false)
    }
    
    private var imageMagnificationFitsToWindow: Bool {
        abs(fittingMagnification - magnification) < 0.01
    }
    
    private func setMagnification(
        to magnification: CGFloat,
        center: CGPoint? = nil,
        animated: Bool
    ) {
        let center = center
        ?? documentView().hud.selectedControlFrame?.center
        ?? documentView().frame.center
        
        (animated ? animator() : self).setMagnification(
            magnification,
            centeredAt: center)
    }
    
    private func isNear(toFit bounds: CGRect) -> Bool {
        let fittingMagnification = fittingMagnification(bounds: bounds)
        
        let isNear = abs(magnification - fittingMagnification) < 0.1
        return isNear
    }
    
    private func fit(to bounds: CGRect, animated: Bool) {
        animator().magnify(toFit: bounds)
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
