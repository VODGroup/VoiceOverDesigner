import XCTest

class ProjectPanel: Robot {
    let window: XCUIElement
    init(window: XCUIElement, app: XCUIApplication) {
        self.window = window
        super.init(app: app)
    }
}
