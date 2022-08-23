import XCTest

class WindowTests: DesignerTests {
    func test_whenCreateNewDocument_shouldCloseProjectWindow() {
        XCTContext.runActivity(named: "When create new project") { _ in
//            projects.createNewProject()
            XCTAssertFalse(projects.projectsWindow.isHittable, "should close Projects")
        }
        
        XCTContext.runActivity(named: "When close project") { _ in
            project.close(delete: false)
            
            XCTAssertTrue(projects.projectsWindow.isHittable, "should reopen Projects")
        }
    }
}
