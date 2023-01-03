import AppKit
import Canvas

class CanvasScrollView: NSScrollView {
    
    weak var hud: HUDLayer?
    
    public override func scrollWheel(with event: NSEvent) {
        let isCommandPressed = event.modifierFlags.contains(.command)
        
        guard isCommandPressed else {
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
    
    override func setMagnification(_ magnification: CGFloat, centeredAt point: NSPoint) {
        super.setMagnification(magnification, centeredAt: point)
        
        updateHud(to: magnification)
    }
    
    func updateHud(to magnification: CGFloat) {
        hud?.scale = 1 / magnification
    }
}
