import XCTest

class ProjectWindow: Robot {
    lazy var projectWindow = app.windows["Untitled"]
    
    @discardableResult
    func selectNewWindow() -> Self {
        
        let splitGroup = projectWindow.children(matching: .splitGroup).element
        splitGroup.click()
        return self
    }
    
    func click(_ coord: CGVector) -> Self {
        projectWindow.coordinate(withNormalizedOffset: coord)
            .press(forDuration: 0.01)
        return self
    }
    
    func close(delete: Bool) {
        projectWindow.buttons[XCUIIdentifierCloseWindow].click()
        if delete {
            projectWindow.sheets.buttons["Delete"].click()
        }
    }
    
    // MARK: Panels
    var textSummary: TextSummary {
        TextSummary(window: projectWindow, app: app)
    }
    
    var canvas: Canvas {
        Canvas(window: projectWindow, app: app)
    }
    
    var settingsPanel: Settings {
        Settings(window: projectWindow, app: app)
    }
}
