import QuartzCore

public class TranslateAction: MoveAction, DraggingAction {

    public func end(at coordinate: CGPoint) -> DraggingAction? {
        if offset.isSmallOffset {
            // Reset frame
            control.frame = control.frame
                .offsetBy(dx: -offset.x,
                          dy: -offset.y)
            return ClickAction(control: control)
        }
        
        return self
    }
    
    public func undo() {
        control.frame = initialFrame
    }
}
