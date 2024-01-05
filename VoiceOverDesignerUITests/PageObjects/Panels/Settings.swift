import XCTest

class Settings: ProjectPanel {
    
    // MARK: - Label
    var resultLabel: XCUIElement { window.splitGroups.staticTexts["ResultLabel"] }
    
    var resultLabelText: String? {
        resultLabel.value as? String
    }
    
    var labelTextField: XCUIElement {
        window.comboBoxes["LabelTextField"].firstMatch
    }
    
    var deleteButton: XCUIElement {
        window.buttons["Delete"].firstMatch
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
    
    @discardableResult
    func delete() -> Self {
        deleteButton.tap()
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
    
    var addValueButton: XCUIElement {
        window.splitGroups.scrollViews.buttons["+ Add value"].firstMatch
    }
    
    @discardableResult
    func addAdjustableVariant(_ text: String) -> Self {
        addValueButton.click()
        
        let newAdjustableOption = app.otherElements["Empty"]
        newAdjustableOption.click()
        newAdjustableOption.input(text, pressEnter: false)
        
        // Element's identifiers have changed
        let newAdjustableOption1 = app.otherElements[text]
        newAdjustableOption1.inputEnter()
        
        return self
    }
    
    @discardableResult
    func selectAdjustable(_ value: String) -> Self {
        window.radioButtons.element(boundBy: 1).click()
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
            inputEnter()
        }
    }
    
    func inputEnter() {
        typeText("\r")
    }
}
