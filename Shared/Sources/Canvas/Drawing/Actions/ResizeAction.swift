import CoreGraphics

public class ResizeAction: DraggingAction {
    init(view: DrawingView, control: A11yControlLayer, startLocation: CGPoint, offset: CGPoint, initialFrame: CGRect, corner: RectCorner) {
        self.view = view
        self.control = control
        self.startLocation = startLocation
        self.offset = offset
        self.initialFrame = initialFrame
        self.corner = corner
    }
    
    private let view: DrawingView
    public let control: A11yControlLayer
    private let startLocation: CGPoint
    private(set) var offset: CGPoint
    public let initialFrame: CGRect
    public let corner: RectCorner
    
    public func drag(to coordinate: CGPoint) {
        let alignedCoordinate = view.alignmentOverlay
            .alignToAny(control,
                        point: coordinate,
                        drawnControls: view.drawnControls)

        control.updateWithoutAnimation {
            let frame = initialFrame
                .move(corner: corner, to: coordinate)
            
            control.update(to: frame, in: view)
        }
    }
    
    public func end(at coordinate: CGPoint) -> DraggingAction? {
        let frame = control.frame.rounded()
        control.update(to: frame, in: view)
        return self
    }
    
    public func cancel() {
        control.updateWithoutAnimation {
            undo()
        }
    }
}

extension ResizeAction: Undoable {
    public func undo() {
        control.update(to: initialFrame, in: view)
    }
}
