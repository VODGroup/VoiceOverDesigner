import XCTest

class DocumentFromFileTests: DesignerTests {
    let fileURL = URL(fileURLWithPath: "/Users/rubanov/Library/Mobile Documents/com~apple~CloudDocs/VoiceOver Design Samples/Ru/Dodo Pizza/Empty.vodesign")
    
    func test_whenOpenDocument_shouldNotShowRecentoProjectsWindow() {
        XCTExpectFailure("It strange that Untitled document restores from previous session")
        
        XCTContext.runActivity(named: "When open document") { _ in
            lauchApp(launchType: .openDocument(documentURL: fileURL))
            XCTAssertFalse(recent.isVisible, "should close Projects")
            XCTAssertEqual(1, app.windows.count, "should open only document")
        }
        
        XCTContext.runActivity(named: "Close document") { _ in
            ProjectWindow(app: app)
                .close(delete: false)
        }
        
        XCTContext.runActivity(named: "When run the app 2nd time should restore window") { _ in
            lauchApp(launchType: .justTapIcon)
            
            XCTAssertFalse(ProjectWindow(app: app).projectWindow.isHittable, "should not restore document window")
            XCTAssertEqual(1, app.windows.count, "should open only document")
        }
    }
}
