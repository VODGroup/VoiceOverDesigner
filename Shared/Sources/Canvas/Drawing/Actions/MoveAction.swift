import QuartzCore
import Artboard

public class MoveAction {
    init(view: DrawingView, control: A11yControlLayer, startLocation: CGPoint, offset: CGPoint, initialFrame: CGRect) {
        self.view = view
        self.control = control
        self.startLocation = startLocation
        self.offset = offset
        self.initialFrame = initialFrame
    }
    
    private let view: DrawingView
    public let control: A11yControlLayer
    private let startLocation: CGPoint
    private(set) var offset: CGPoint
    let initialFrame: CGRect
    
    public func drag(to coordinate: CGPoint) {
        let offset = coordinate - startLocation
        
        let frame = initialFrame
            .offsetBy(dx: offset.x,
                      dy: offset.y)
        
        let aligned = view.alignmentOverlay.alignToAny(control, frame: frame, drawnControls: view.drawnControls)
        
        control.updateWithoutAnimation {
            let alignedOffset = aligned.origin - control.frame.origin
            control.updateFrame(aligned)
            
            if let container = control.model as? any ArtboardContainer {
                // Won't work on nested containers or should be recursive
                for layer in view.drawnControls(for: container) {
                    let frame = layer.frame
                        .offsetBy(dx: alignedOffset.x, dy: alignedOffset.y)
                    
                    layer.updateFrame(frame)
                }
            }
        }
        
        self.offset = offset
    }
}
