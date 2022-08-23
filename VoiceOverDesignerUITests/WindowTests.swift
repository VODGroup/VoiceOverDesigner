import XCTest

class WindowTests: DesignerTests {
    func test_whenCreateNewDocument_shouldCloseProjectWindow() {
        XCTExpectFailure("No recent to show")
        
        lauchApp()
        
        XCTContext.runActivity(named: "When create new project") { _ in
            XCTAssertFalse(projects.projectsWindow.isHittable, "should close Projects")
        }
        
        XCTContext.runActivity(named: "When close project") { _ in
            project.close(delete: false)
            
            XCTAssertTrue(projects.projectsWindow.isHittable, "should reopen Projects")
        }
    }
}


