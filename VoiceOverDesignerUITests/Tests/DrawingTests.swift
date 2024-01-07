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
        
        project.verify(controlDescription: "Title. Heading.")
    }
    
    func test_draw_delete_undo_shouldDrawAgain_andSelect() {
        launchApp()
        project.newDocument()
        
        canvas
            .drawRectInCenter()
        
        settings
            .inputLabel("Title")
            .delete()
        
        project.undo()
        
        project.verifyNavigator(controlDescription: "Title")
        project.verifySettings(controlDescription: "Title") // Is selected
    }
}
