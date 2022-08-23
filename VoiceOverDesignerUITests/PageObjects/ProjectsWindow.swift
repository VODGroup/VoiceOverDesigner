import XCTest

class ProjectsWindow: Robot {
    func createNewProject() {
        app.windows["VoiceOver Designer"].toolbars.buttons["New"].click()
    }
}
