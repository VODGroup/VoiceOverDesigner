import QuartzCore

public class TranslateAction: MoveAction, DraggingAction {

    public func end(at coordinate: CGPoint) -> DraggingAction? {
        if offset.isSmallOffset {
            // Reset frame
            let frame = control.frame
                .offsetBy(dx: -offset.x,
                          dy: -offset.y)
            
            control.update(to: frame, in: view)
            return ClickAction(control: control)
        }
        
        return self
    }
    
    public func cancel() {
        control.updateWithoutAnimation {
            undo()
        }
    }
}

extension TranslateAction: Undoable {
    public func undo() {
        control.updateWithoutAnimation {
            control.update(to: initialFrame, in: view)
        }
    }
}
