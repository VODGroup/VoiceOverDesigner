import XCTest

class RecentWindow: Robot {
    var recentWindow: XCUIElement {
        app.windows["VoiceOver Designer"]
    }
    
    func createNewProject() {
        recentWindow.toolbars.buttons["New"].click()
    }
    
    var isVisible: Bool {
        recentWindow.isHittable
    }
}
