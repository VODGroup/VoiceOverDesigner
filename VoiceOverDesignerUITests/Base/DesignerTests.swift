import XCTest

class DesignerTests: XCTestCase {
    
    var app: XCUIApplication!
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
    }
    
    enum LaunchType {
        case justTapIcon
        case openDocument
        case createNewAndCloseRecent
    }
    
    func lauchApp(documentURL: URL? = nil) {
        app.launchEnvironment["DocumentURL"] = documentURL?.standardizedFileURL.absoluteString ?? ""
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
