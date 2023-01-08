import XCTest

class DrawingTests: DocumentTests {
    func test_whenDrawAnElement_shouldUpdateTitleEverywhere() throws {
        lauchApp()
        
        recent.createNewProject()
        
        // TODO: Add empty image to canvas
        canvas
            .drawRectInCenter()
        
        settings
            .inputLabel("Title")
            .clickHeaderTrait()

        project.verify(controlDescription: "Title. Heading.")
    }
}
