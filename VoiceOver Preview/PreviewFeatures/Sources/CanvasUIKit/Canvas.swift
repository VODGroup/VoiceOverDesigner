import UIKit
import Document
import Canvas
import VoiceOverLayout

class Canvas: UIView, DrawingView {
    var hud = HUDLayer()
    
    var escListener: EscModifierAction = EmptyEscModifierAction()
    
    var drawnControls: [A11yControlLayer] = []
    
    var alignmentOverlay: AlignmentOverlayProtocol = NoAlignmentOverlay()
    
    var scale: CGFloat = 1
    
    var copyListener: CopyModifierAction = ManualCopyCommand()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: Find better place
        addHUD()
    }
}
