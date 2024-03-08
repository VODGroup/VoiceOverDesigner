import QuartzCore

public class TranslateAction: MoveAction {

    public override func end(at coordinate: CGPoint) -> DraggingAction? {
        if offset.isSmallOffset {
            // Reset frame
            let frame = control.frame
                .offsetBy(dx: -offset.x,
                          dy: -offset.y)
            
            control.update(to: frame, in: view, offset: offset)
            return ClickAction(control: control)
        }
        
        return super.end(at: coordinate)
    }
}

extension TranslateAction: Undoable {
    public func undo() {
        cancel()
    }
}
