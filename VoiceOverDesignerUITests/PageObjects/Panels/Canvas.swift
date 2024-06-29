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
    
    @discardableResult
    func click(dx: Double, dy: Double) -> Self {
        let window = app.windows.firstMatch
        let assertClick = CGVector(dx: dx, dy: dy)
        let tapTest = window.coordinate(withNormalizedOffset: assertClick)
        tapTest.press(forDuration: 0.01)
        
        return self
    }
    
    @discardableResult
    func deselect(dx: Double, dy: Double) -> Self {
        click(dx: dx, dy: dy)
        XCTAssertTrue(app.staticTexts["Select or draw a control\nto adjust settings"].exists)
        
        return self
    }
    
    @discardableResult
    func select(dx: Double, dy: Double) -> Self {
        click(dx: dx, dy: dy)
        XCTAssertFalse(app.staticTexts["Select or draw a control\nto adjust settings"].exists)
        
        return self
    }
    
    @discardableResult
    func drag(from: Double, to: Double) -> Self {
        let from = CGVector(dx: from, dy: from)
        let to = CGVector(dx: to, dy: to)
        
        let window = app.windows.firstMatch
        let start   = window.coordinate(withNormalizedOffset: from)
        let finish  = window.coordinate(withNormalizedOffset: to)
        
        start.press(forDuration: 0.01, thenDragTo: finish)
        
        return self
    }
        
        @discardableResult
        func assertNoElements() -> Self {
            let assertNoElementsCanvas: () = XCTAssertTrue(app.staticTexts["Add your screenshot"].exists)
            
            return self
        }
    
    @discardableResult
    func assertHaveElements() -> Self {
        let assertHaveElementsCanvas: () = XCTAssertFalse(app.staticTexts["Add your screenshot"].exists)
        
        return self
    }
        
}
