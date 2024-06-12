import XCTest

class Navigator: ProjectPanel {
    
    var navigator: XCUIElement { window.outlines.firstMatch }
    
    @discardableResult
    func groupInContainer() -> Self {
        app.buttons["Group in Container"].click()
        
        return self
    }
    
    @discardableResult
    func assertFirstCell(
        text: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self  {
        let actualText = navigator.cells.staticTexts.firstMatch.value as? String
        
        XCTAssertEqual(actualText, text, file: file, line: line)
        return self
    }
}
