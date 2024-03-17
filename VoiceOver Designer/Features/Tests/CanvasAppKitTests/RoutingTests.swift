import XCTest
@testable import Canvas

@MainActor
class RoutingTests: CanvasAfterDidLoadTests {
    
    func test_openSettings() async throws {
        drawRect_10_60()
        
        
        // MARK: "click outside"
        sut.click(coordinate: .coord(0))
        
        XCTAssertNil(sut.selectedControl, "should deselect iten")
        
        let selected1 = try await awaitSelected()
        XCTAssertNil(selected1, "should not select after translation")
    
        
        // MARK: open settings after click
        
        sut.mouseDown(on: .coord(10))
        let selected2 = try await awaitSelected()
        XCTAssertNil(selected2, "should not select after translation")
        
        sut.mouseUp(on: .coord(11)) // Slightly move is possible
        let selected3 = try await awaitSelected()
        XCTAssertNotNil(selected3, "show settings on touch up")
        
        XCTAssertEqual(drawnControls.first?.frame,
                       rect10to50, "Keep frame")
        
        XCTAssertNotNil(sut.selectedControl, "should select visually")
    }
}
