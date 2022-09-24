import AppKit

class FlippedView: NSView {
    override var isFlipped: Bool {
        true
    }
}

class FlippedStackView: NSStackView {
    override var isFlipped: Bool {
        true
    }
}
