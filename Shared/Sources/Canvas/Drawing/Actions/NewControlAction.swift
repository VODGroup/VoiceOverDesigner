import QuartzCore

public class NewControlAction: DraggingAction {
    public func cancel() {
        view.delete(control: control)
    }
    
    init(view: DrawingView, control: ArtboardElementLayer, coordinate: CGPoint) {
        self.view = view
        self.control = control
        self.origin = view.alignmentOverlay.alignToAny(control, point: coordinate, drawnControls: view.drawnControls)
    }
    
    private let view: DrawingView
    public let control: ArtboardElementLayer
    private let origin: CGPoint
    
    public func drag(to coordinate: CGPoint) {
        let alignedCoordinate = view.alignmentOverlay.alignToAny(control, point: coordinate, drawnControls: view.drawnControls)
        control.updateWithoutAnimation {
            let frame = CGRect(
                x: origin.x,
                y: origin.y,
                width: alignedCoordinate.x - origin.x,
                height: alignedCoordinate.y - origin.y)
            
            control.update(to: frame, in: view)
        }
    }
    
    public func end(at coordinate: CGPoint) -> DraggingAction? {
        if control.frame.size.width < 5 || control.frame.size.height < 5 {
            view.delete(control: control)
            return .none
        }
        
        let minimalTapSize: CGFloat = 44
        let minimalSize: CGSize = CGSize(width: minimalTapSize, height: minimalTapSize)
        
        let frame = control.frame.increase(to: minimalSize).rounded()
        
        control.update(to: frame, in: view)
        return self
    }
}
