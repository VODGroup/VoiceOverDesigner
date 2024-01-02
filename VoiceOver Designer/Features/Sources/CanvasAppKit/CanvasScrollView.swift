import AppKit
import CommonUI
import Canvas

protocol ScrollViewScrollingDelegate: AnyObject {
    func didUpdateScale(_ magnification: CGFloat)
}

class CanvasScrollView: NSScrollView {
    
    weak var delegate: ScrollViewScrollingDelegate?
    
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
    
    // Update after any change of position or magnification
    override func reflectScrolledClipView(_ cView: NSClipView) {
        super.reflectScrolledClipView(cView)
        
        delegate?.didUpdateScale(magnification)
    }
}
