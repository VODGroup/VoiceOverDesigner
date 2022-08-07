import QuartzCore

public class NewControlAction: DraggingAction {
    
    init(view: DrawingView, control: A11yControl, coordinate: CGPoint) {
        self.view = view
        self.control = control
        self.origin = view.alignmentOverlay.alignToAny(control, point: coordinate, drawnControls: view.drawnControls)
    }
    
    private let view: DrawingView
    public let control: A11yControl
    private let origin: CGPoint
    
    public func drag(to coordinate: CGPoint) {
        let alignedCoordinate = view.alignmentOverlay.alignToAny(control, point: coordinate, drawnControls: view.drawnControls)
        control.updateWithoutAnimation {
            control.frame = CGRect(x: origin.x,
                                   y: origin.y,
                                   width: alignedCoordinate.x - origin.x,
                                   height: alignedCoordinate.y - origin.y)
        }
    }
    
    public func end(at coodrinate: CGPoint) -> DraggingAction? {
        if control.frame.size.width < 5 || control.frame.size.height < 5 {
            view.delete(control: control)
            return .none
        }
        
        let minimalTapSize: CGFloat = 44
        control.frame = control.frame.increase(to: CGSize(width: minimalTapSize, height: minimalTapSize))
        return self
    }
}
