import CoreGraphics

public class CopyAction: MoveAction, DraggingAction {
    public func cancel() {
        control.updateWithoutAnimation {  
            control.update(to: initialFrame, in: view)
        }
    }
    
    public func end(at coordinate: CGPoint) -> DraggingAction? {
        return self
    }
}
