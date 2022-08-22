import XCTest

class DrawingTests: DocumentTests {
    func test_whenDrawAnElement_shouldUpdateTitleEverywhere() throws {
        canvas
            .drawRectInCenter()
        
        settings
            .inputLabel("Title")
            .clickHeaderTrait()

        XCTContext.runActivity(named: "Name should be set to text and settings header") { _ in
            let resultText = "Title. Heading."
            XCTAssertEqual(textSummary.firstCellText, resultText)
            XCTAssertEqual(settings.resultLabelText, resultText)
        }
    }
}
