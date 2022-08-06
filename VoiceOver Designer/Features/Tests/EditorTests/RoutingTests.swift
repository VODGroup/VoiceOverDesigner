import XCTest
@testable import Editor

class RoutingTests: EditorAfterDidLoadTests {
    func test_openSettings() {
        drawRect_10_60()
        
        XCTContext.runActivity(named: "click outside") { _ in
            sut.click(coordinate: .coord(0))
            
            XCTAssertNil(sut.selectedControl, "should deselect iten")
            XCTAssertFalse(router.isSettingsShown)
        }
        
        XCTContext.runActivity(named: "open settings after click") { _ in
            sut.mouseDown(on: .coord(10))
            XCTAssertFalse(router.isSettingsShown, "not show settings on touch down")
            
            sut.mouseUp(on: .coord(11)) // Slightly move is possible
            XCTAssertTrue(router.isSettingsShown, "show settings on touch up")
            
            XCTAssertEqual(drawnControls.first?.frame,
                           rect10to50, "Keep frame")
            
            XCTAssertNotNil(sut.selectedControl)
        }
    }
}
