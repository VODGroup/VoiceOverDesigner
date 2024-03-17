import QuartzCore

public struct ClickAction: DraggingAction {
    public let control: ArtboardElementLayer
    
    public func drag(to coordinate: CGPoint) {
        
    }
    
    public func end(at coordinate: CGPoint) -> DraggingAction? {
        return self
    }
    
    public func cancel() {
        
    }
}
