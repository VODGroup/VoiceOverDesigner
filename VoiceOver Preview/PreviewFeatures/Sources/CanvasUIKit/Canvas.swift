import UIKit
import Document
import Canvas
import VoiceOverLayout

class Canvas: UIView, DrawingView {
    
    var drawnControls: [A11yControlLayer] = []
    var frames: [ImageLayer] = []
    
    var hud = HUDLayer()
    var alignmentOverlay: AlignmentOverlayProtocol = NoAlignmentOverlay()
    
    var scale: CGFloat = 1
    
    var copyListener: CopyModifierAction = ManualCopyCommand()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: Find better place
        addHUD()
    }
}
