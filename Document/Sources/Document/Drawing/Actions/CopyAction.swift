import QuartzCore

public class MoveAction {
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
    private(set) var offset: CGPoint
    let initialFrame: CGRect
    
    public func drag(to coordinate: CGPoint) {
        let offset = coordinate - startLocation
        
        let frame = initialFrame
            .offsetBy(dx: offset.x,
                      dy: offset.y)
        
        let aligned = view.alingmentOverlay.alignToAny(control, frame: frame, drawnControls: view.drawnControls)
        
        control.updateWithoutAnimation {
            control.frame = aligned
        }
        
        self.offset = offset
    }
}

public class CopyAction: MoveAction, DraggingAction {
    
    public func end(at coordinate: CGPoint) -> DraggingAction? {
        return self
    }
}
