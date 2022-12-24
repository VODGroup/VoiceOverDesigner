import UIKit
import Document
import Canvas
import VoiceOverLayout

class Canvas: UIView, DrawingView {
    var escListener: EscModifierAction = EmptyEscModifierAction()
    
    var drawnControls: [A11yControlLayer] = []
    
    var alignmentOverlay: AlignmentOverlayProtocol = NoAlignmentOverlay()
    
    var layout: VoiceOverLayout? {
        didSet {
            accessibilityElements = layout?.accessibilityElements
        }
    }
    
    var scale: CGFloat = 1
    
    var copyListener: CopyModifierProtocol = ManualCopyCommand()
}
