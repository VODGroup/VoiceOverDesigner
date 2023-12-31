import AppKit
import CommonUI
import Canvas

class CanvasScrollView: NSScrollView {
    
    weak var hud: HUDLayer?
    weak var dragNDropImageView: DragNDropImageView?
    
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
    
    override func reflectScrolledClipView(_ cView: NSClipView) {
        super.reflectScrolledClipView(cView)
        
        updateHud(to: magnification)
    }
    
    private func updateHud(to magnification: CGFloat) {
        hud?.scale = 1 / magnification
        dragNDropImageView?.scale = magnification
    }
}
