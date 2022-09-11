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
        
        return self
    }
}
