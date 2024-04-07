import QuartzCore

public protocol DraggingAction {
    func drag(to coordinate: CGPoint)
    func end(at coordinate: CGPoint) -> DraggingAction?
    func cancel()
    
    var control: ArtboardElementLayer { get }
}
