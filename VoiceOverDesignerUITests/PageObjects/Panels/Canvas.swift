import XCTest

class Canvas: ProjectPanel {
    @discardableResult
    func draw(from: CGVector, to: CGVector) -> Self {
        let start   = window.coordinate(withNormalizedOffset: from)
        let finish  = window.coordinate(withNormalizedOffset: to)
        start.press(forDuration: 0.01, thenDragTo: finish)
        return self
    }
    
    @discardableResult
    func drawRectInCenter() -> Self {
        draw(from: .init(dx: 0.4, dy: 0.4),
             to: .init(dx: 0.5, dy: 0.5))
        
        // TODO: Expose drawing rect as separate element
        
        return self
    }
    
    @discardableResult
    func tap(_ location: CGVector) -> Self {
        let start   = window.coordinate(withNormalizedOffset: location)
        start.press(forDuration: 0.01)
        
        return self
    }
    
    @discardableResult
    func deselect() -> Self {
        tap(.init(dx: 0.3, dy: 0.3))
        return self
    }
    
    @discardableResult
    func select(_ location: CGVector) -> Self {
        tap(location)
        return self
    }
}
