import AppKit

class CanvasScrollView: NSScrollView {
    public override func scrollWheel(with event: NSEvent) {
        guard event.modifierFlags.contains(.option) else {
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
