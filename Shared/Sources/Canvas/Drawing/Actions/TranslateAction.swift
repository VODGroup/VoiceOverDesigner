import QuartzCore

public class TranslateAction: MoveAction, DraggingAction {

    public func end(at coordinate: CGPoint) -> DraggingAction? {
        if offset.isSmallOffset {
            // Reset frame
            let frame = control.frame
                .offsetBy(dx: -offset.x,
                          dy: -offset.y)
            
            control.updateFrame(frame)
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
        control.updateFrame(initialFrame)
    }
}
