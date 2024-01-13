import XCTest

class SettingsTests: DocumentTests {
    func test_whenDrawAnElement_shouldUpdateTitleEverywhere() throws {
        launchApp(.createNewAndCloseRecent)
        
        canvas
            .drawRectInCenter()
        
        settings
            .inputLabel("Title")
            .clickHeaderTrait()
        
        project.verify(controlDescription: "Title. Heading.")
    }
    
    func test_draw_delete_undo_shouldDrawAgain_andSelect() {
        launchApp(.createNewAndCloseRecent)
        
        canvas
            .drawRectInCenter()
        
        settings
            .inputLabel("Title")
            .delete()
        
        project.undo()
        
        project.verifyNavigator(controlDescription: "Title")
        project.verifySettings(controlDescription: "Title") // Is selected
    }
    
    func test_customActions_shouldBePublishedToArtboard() {
        launchApp(.createNewAndCloseRecent)
        
        canvas
            .drawRectInCenter()
        
        settings
            .addCustomAction("Action")
        
        canvas
            .deselect()
            .select(.init(dx: 0.45, dy: 0.45)) // select
        
        XCTAssertEqual(settings.customActionLabel(), "Action")
    }
    
    func test_customDescription_shouldBePublishedToArtboard() {
        launchApp(.createNewAndCloseRecent)
        
        canvas
            .drawRectInCenter()
        
        settings
            .addCustomDescription("Label", value: "Value")
        
        canvas
            .deselect()
            .select(.init(dx: 0.45, dy: 0.45)) // select
        
        XCTAssertEqual(settings.customDescriptionLabel(), "Label")
        XCTAssertEqual(settings.customDescriptionValue(), "Value")
    }
}
