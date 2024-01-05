import XCTest

class DrawingTests: DocumentTests {
    func test_whenDrawAnElement_shouldUpdateTitleEverywhere() throws {
        launchApp()
        project.newDocument()
        
        canvas
            .drawRectInCenter()
        
        settings
            .inputLabel("Title")
            .clickHeaderTrait()
        
        project.verifySettings(controlDescription: "Title. Heading.")
        
        // Deselect
        // TODO: no need for deselect
        canvas.draw(from: .init(dx: 0.4, dy: 0.4),
                    to: .init(dx: 0.4, dy: 0.4))
        project.verifyNavigator(controlDescription: "Title. Heading.")
        
        // TODO: Should be possible to verify at once
//        project.verify(controlDescription: "Title. Heading.")
    }
    
    func test_draw_delete_undo_shouldDrawAgain() {
        launchApp()
        project.newDocument()
        
        canvas
            .drawRectInCenter()
        
        settings
            .inputLabel("Title")
            .delete()
        
        project.undo()
        
        project.verifyNavigator(controlDescription: "Title")
    }
}
