import UIKit
import Document
import Canvas

class Canvas: UIView, DrawingView {
    var escListener: EscModifierAction = EmptyEscModifierAction()
    
    var drawnControls: [A11yControl] = []
    
    var alignmentOverlay: AlignmentOverlayProtocol = NoAlignmentOverlay()
    
    var layout: VoiceOverLayout? {
        didSet {
            accessibilityElements = layout?.accessibilityElements
        }
    }
    
    var scale: CGFloat = 1
    
    var copyListener: CopyModifierProtocol = ManualCopyCommand()
}
