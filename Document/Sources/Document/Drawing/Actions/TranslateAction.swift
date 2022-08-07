import QuartzCore

public class TranslateAction: DraggingAction {
    init(view: DrawingView, control: A11yControl, startLocation: CGPoint, offset: CGPoint, initialFrame: CGRect) {
        self.view = view
        self.control = control
        self.startLocation = startLocation
        self.offset = offset
        self.initialFrame = initialFrame
    }
    
    private let view: DrawingView
    public let control: A11yControl
    private let startLocation: CGPoint
    private var offset: CGPoint
    private let initialFrame: CGRect
    
    public func drag(to coordinate: CGPoint) {
        let offset = coordinate - startLocation
        
        let frame = initialFrame
            .offsetBy(dx: offset.x,
                      dy: offset.y)
        
        let aligned = view.alignmentOverlay.alignToAny(control, frame: frame, drawnControls: view.drawnControls)
        
        control.updateWithoutAnimation {
            control.frame = aligned
        }
        
        self.offset = offset
    }
    
    public func end(at coodrinate: CGPoint) -> DraggingAction? {
        if offset.isSmallOffset {
            // Reset frame
            control.frame = control.frame
                .offsetBy(dx: -offset.x,
                          dy: -offset.y)
            return ClickAction(control: control)
        }
        
        return self
    }
    
    public func undo() {
        control.frame = initialFrame
    }
}
