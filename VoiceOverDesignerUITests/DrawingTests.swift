import XCTest

class DrawingTests: DocumentTests {
    func test_whenDrawAnElement_shouldUpdateTitleEverywhere() throws {
        lauchApp()
        
        canvas
            .drawRectInCenter()
        
        settings
            .inputLabel("Title")
            .clickHeaderTrait()

        project.verify(controlDescription: "Title. Heading.")
    }
}
