import QuartzCore
import Artboard

public class MoveAction: DraggingAction {

    init(view: DrawingView, control: ArtboardElementLayer, startLocation: CGPoint, offset: CGPoint, initialFrame: CGRect) {
        self.view = view
        self.control = control
        self.startLocation = startLocation
        self.offset = offset
        self.initialFrame = initialFrame
    }
    
    let view: DrawingView
    public let control: ArtboardElementLayer
    private let startLocation: CGPoint
    private(set) var offset: CGPoint
    let initialFrame: CGRect
    
    public func drag(to coordinate: CGPoint) {
        let offset = coordinate - startLocation
        
        let frame = initialFrame
            .offsetBy(dx: offset.x,
                      dy: offset.y)
        
        let aligned = view.alignmentOverlay.alignToAny(
            control,
            frame: frame,
            drawnControls: view.drawnControls)
        
        control.updateWithoutAnimation {
            control.update(to: aligned, in: view)
        }
        
        self.offset = offset
    }
    
    public func end(at coordinate: CGPoint) -> DraggingAction? {
        updateNestedLayersIfNeeded()
        return self
    }
    
    public func cancel() {
        control.updateWithoutAnimation {
            control.update(to: initialFrame, in: view)
            updateNestedLayersIfNeeded()
        }
    }
    
    private func updateNestedLayersIfNeeded() {
        if let container = control.model as? any ArtboardContainer {
            view.recalculateAbsoluteFrameForNestedElements(in: container)
        }
    }
}
