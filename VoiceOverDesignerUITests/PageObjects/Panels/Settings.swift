import XCTest

class Settings: ProjectPanel {
    
    // MARK: - Label
    var resultLabel: XCUIElement { window.splitGroups.staticTexts.firstMatch }
    
    var resultLabelText: String? {
        resultLabel.value as? String
    }
    
    var labelTextField: XCUIElement {
        window
            .splitGroups
            .textFields["labelTextField"]
    }
    
    @discardableResult
    func inputLabel(
        _ text: String
    ) -> Self {
        XCTContext.runActivity(named: "Input label: \(text)") { _ in
            labelTextField.input(text)
        }
        
        return self
    }
    
    // MARK: - Value
    var valueTextField: XCUIElement {
        window
            .splitGroups
            .textFields["valueTextField"]
    }
    
    @discardableResult
    func inputValue(
        _ text: String
    ) -> Self {
        XCTContext.runActivity(named: "Input value: \(text)") { _ in
            valueTextField.input(text)
        }
        return self
    }
    
    var adjustableCheckbox: XCUIElement {
        window.splitGroups.scrollViews.checkBoxes["Adjustable"]
    }
    
    @discardableResult
    func clickAdjustable() -> Self {
        adjustableCheckbox.click()
        return self
    }
    
    @discardableResult
    func addAdjustableVariant(_ text: String) -> Self {
        // TODO: Add code
        return self
    }
    
    @discardableResult
    func selectAdjustable(_ value: String) -> Self {
        
        return self
    }
    
    // MARK: - Traits
    var traitHeaderCheckbox: XCUIElement {
        window.splitGroups.scrollViews.checkBoxes["Header"]
    }
    
    @discardableResult
    func clickHeaderTrait() -> Self {
        traitHeaderCheckbox.click()
        return self
    }
}

extension XCUIElement {
    func input(_ text: String, pressEnter: Bool = true) {
        click()
        typeText(text)
        
        if pressEnter {
            typeText("\r")
        }
    }
}
