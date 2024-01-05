import XCTest

class AdjustableTest: DocumentTests {
    func test_whenCreateAdjustable_andSelectAnotherVariant_shouldUpdateTitle() {
        launchApp()
        project.newDocument()
        
        canvas.drawRectInCenter()
        
        // TODO: Pizza ize and Meium not a mistakes! It accidentely calls save dialog
        XCTContext.runActivity(named: "Fill adjustable") { _ in
            settings
                .inputLabel("Pizza ize")
                .inputValue("Small")
                .clickAdjustable()
            
            project.verify(controlDescription: "Pizza ize: Small. Adjustable.")
            
            settings
                .addAdjustableVariant("Meium")
                .selectAdjustable("Meium")
            
            project.verify(controlDescription: "Pizza ize: Meium, 2 of 2. Adjustable.")
        }
        
        XCTContext.runActivity(named: "Disable adjustable") { _ in
            settings
                .clickAdjustable()
            
            project.verify(controlDescription: "Pizza ize: Meium")
        }
    }
}
