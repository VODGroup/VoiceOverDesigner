import CoreGraphics

public class ResizeAction: DraggingAction {
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
    public let initialFrame: CGRect
    
    public func drag(to coordinate: CGPoint) {
        let alignedCoordinate = view.alignmentOverlay.alignToAny(control, point: coordinate, drawnControls: view.drawnControls)
        
        control.updateWithoutAnimation {
            control.frame = CGRect(x: initialFrame.minX,
                                   y: initialFrame.minY,
                                   width: alignedCoordinate.x - initialFrame.minX,
                                   height: alignedCoordinate.y - initialFrame.minY)
        }
    }
    
    public func end(at coordinate: CGPoint) -> DraggingAction? {
        return self
    }
    
    public func cancel() {
        control.updateWithoutAnimation {
            control.frame = initialFrame
        }
    }
}
