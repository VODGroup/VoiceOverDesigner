import XCTest

class AdjustableTest: DocumentTests {
    func test_whenCreateAdjustable_andSelectAnotherVariant_shouldUpdateTitle() {
        canvas.drawRectInCenter()
        
        settings
            .inputLabel("Pizza ize")
            .inputValue("Small")
            .clickAdjustable()
        
        project.verify(controlDescription: "Pizza ize: Small. Adjustable.")
        
        settings
            .addAdjustableVariant("Medium")
            .selectAdjustable("Medium")
        
        // TODO: Verify that text represents second variant
    }
}
