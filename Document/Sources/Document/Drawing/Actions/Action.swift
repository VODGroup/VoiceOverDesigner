import QuartzCore

public protocol DraggingAction {
    func drag(to coordinate: CGPoint)
    func end(at coodrinate: CGPoint) -> DraggingAction?
}
