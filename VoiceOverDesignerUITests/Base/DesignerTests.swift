import XCTest

class DesignerTests: XCTestCase {
    
    var app: XCUIApplication!
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
    }
    
    func lauchApp(documentURL: URL? = nil) {
        if let documentURL = documentURL {
            app.launchArguments.append("-DocumentURL")
            app.launchArguments.append(documentURL.standardizedFileURL.absoluteString)
        }
        app.launch()
    }
    
    var projects: ProjectsWindow {
        ProjectsWindow(app: app)
    }
    
    var project: ProjectWindow {
        ProjectWindow(app: app)
    }
    
    // MARK: Panels
    var textSummary: TextSummary {
        project.textSummary
    }
    
    var canvas: Canvas {
        project.canvas
    }
    
    var settings: Settings {
        project.settingsPanel
    }
}
