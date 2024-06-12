import XCTest

class DesignerTests: XCTestCase {
    
    var app: XCUIApplication!
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        
        app = XCUIApplication()
    }
    
    enum LaunchType {
        case justTapIcon
        case openDocument(documentURL: URL)
        case createNewAndCloseRecent
    }
    
    func launchApp(_ launchType: LaunchType = .justTapIcon) {
        app.launchEnvironment["DocumentURL"] = ""
        
        switch launchType {
        case .justTapIcon:
            break // Do nothing
        case .openDocument(let documentURL):
            app.launchEnvironment["DocumentURL"] = documentURL.standardizedFileURL.absoluteString
        case .createNewAndCloseRecent:
            // Do nothing here
            break
        }
        
        app.launch()
        
        if case .createNewAndCloseRecent = launchType {
//            let recent = RecentWindow(app: app)
//            if recent.recentWindow.isHittable {
//                recent.createNewProject()
//            }
            project.newDocument()
        }
    }
    
    var recent: RecentWindow {
        RecentWindow(app: app)
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
    
    func closeWindow() {
        app.windows.firstMatch.buttons[XCUIIdentifierCloseWindow].click()
    }
}
