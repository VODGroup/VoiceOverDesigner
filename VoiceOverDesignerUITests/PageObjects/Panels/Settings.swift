import XCTest

class Settings: ProjectPanel {
    
    var resultLabel: XCUIElement { window.splitGroups.staticTexts.firstMatch }
    
    var resultLabelText: String? {
        resultLabel.value as? String
    }
    
    func inputLabel(
        _ text: String,
        pressEnter: Bool = true
    ) -> Self {
        XCTContext.runActivity(named: "Input \(text)") { _ in
            let labelTextField = window
                .splitGroups
                .textFields["labelTextField"]
            
            labelTextField.click()
            labelTextField.typeText("\(text)")
            
            if pressEnter {
                labelTextField.typeText("\r")
            }
        }
        
        return self
    }
    
    @discardableResult
    func clickHeaderTrait() -> Self {
        window.splitGroups.scrollViews.checkBoxes["Header"].click()
        return self
    }
}
