import XCTest

class WindowTests: DesignerTests {
    func test_whenCreateNewDocument_shouldCloseProjectWindow() {
        XCTExpectFailure("No recent to show")
        
        launchApp()
        
        XCTContext.runActivity(named: "When create new project") { _ in
            XCTAssertFalse(recent.isVisible, "should close Projects")
        }
        
        XCTContext.runActivity(named: "When close project") { _ in
            project.close(delete: false)
            
            XCTAssertTrue(recent.isVisible, "should reopen Projects")
        }
    }
}


