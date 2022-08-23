import XCTest

class ProjectsWindow: Robot {
    var projectsWindow: XCUIElement {
        app.windows["VoiceOver Designer"]
    }
    
    func createNewProject() {
        projectsWindow.toolbars.buttons["New"].click()
    }
}
