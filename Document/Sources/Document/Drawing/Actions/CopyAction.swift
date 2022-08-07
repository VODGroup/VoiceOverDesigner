import CoreGraphics

public class CopyAction: MoveAction, DraggingAction {
    
    public func end(at coordinate: CGPoint) -> DraggingAction? {
        return self
    }
}
