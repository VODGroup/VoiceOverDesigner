import XCTest

class WindowTests: DesignerTests {
    func test_whenCreateNewDocument_shouldCloseProjectWindow() {
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

class DocumentFromFileTests: DesignerTests {
    let fileURL = URL(fileURLWithPath: "/Users/rubanov/Library/Mobile Documents/com~apple~CloudDocs/VoiceOver Design Samples/Ru/Dodo Pizza/Empty.vodesign")
    
    func test_whenOpenDocument_shouldNotShowRecentoProjectsWindow() {
        lauchApp(documentURL: fileURL)
        XCTAssertFalse(projects.projectsWindow.isHittable, "should close Projects")
    }
}
