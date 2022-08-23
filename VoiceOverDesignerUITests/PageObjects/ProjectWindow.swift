import XCTest

class ProjectWindow: Robot {
    var title: String
    init(title: String = "Untitled", app: XCUIApplication) {
        self.title = title
        super.init(app: app)
    }
    
    lazy var projectWindow = app.windows[title]
    
    @discardableResult
    func selectNewWindow() -> Self {
        
        let splitGroup = projectWindow.children(matching: .splitGroup).element
        splitGroup.click()
        return self
    }
    
    @discardableResult
    func click(_ coord: CGVector) -> Self {
        projectWindow.coordinate(withNormalizedOffset: coord)
            .press(forDuration: 0.01)
        return self
    }
    
    @discardableResult
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
    
    // MARK: Assert
    func verify(controlDescription: String,
                file: StaticString = #file, line: UInt = #line) {
        XCTContext.runActivity(named: "Name should be set to text and settings header") { _ in
            XCTAssertEqual(textSummary.firstCellText, controlDescription,
                           file: file, line: line)
            XCTAssertEqual(settingsPanel.resultLabelText, controlDescription,
                           file: file, line: line)
        }
    }
}
