import AppKit

class CanvasScrollView: NSScrollView {
    
    public override func scrollWheel(with event: NSEvent) {
        let isCommandPressed = event.modifierFlags.contains(.command)
        
        guard isCommandPressed else {
            super.scrollWheel(with: event)
            return
        }
        
        let dy = event.deltaY
        if dy != 0.0 {
            let magnification = magnification + dy/30
            let point = contentView.convert(event.locationInWindow, from: nil)
            
            setMagnification(magnification, centeredAt: point)
        }
    }
}
