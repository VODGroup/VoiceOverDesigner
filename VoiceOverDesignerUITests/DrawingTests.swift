import XCTest

class DrawingTests: DocumentTests {
    func test_whenDrawAnElement_shouldUpdateTitleEverywhere() throws {
        canvas
            .drawRectInCenter()
        
        settings
            .inputLabel("Title")
            .clickHeaderTrait()

        project.verify(controlDescription: "Title. Heading.")
    }
}
