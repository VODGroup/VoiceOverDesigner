import AppKit

class FlippedView: NSView {
    override var isFlipped: Bool {
        true
    }
    
    override func layout() {
        super.layout()
        
        layer?.masksToBounds = false
    }
}

class FlippedStackView: NSStackView {
    override var isFlipped: Bool {
        true
    }
}
