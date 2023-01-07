import XCTest

class RecentWindow: Robot {
    var recentWindow: XCUIElement {
        app.windows.firstMatch
    }
    
    func createNewProject() {
        recentWindow.collectionViews.firstMatch.groups["New"].click()
    }
    
    var isVisible: Bool {
        recentWindow.isHittable
    }
    
    func close() {
        recentWindow.buttons[XCUIIdentifierCloseWindow].click()
    }
}
