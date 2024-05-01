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
            .comboBoxes["valueTextField"]
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
    
    var adjustableSegment: XCUIElement {
        // SwiftUI
//        window
//            .radioGroups["Type"]
//            .radioButtons["Adjustable"]
//            .firstMatch
        
        window
            .checkBoxes["Adjustable"]
            .firstMatch
    }
    
    @discardableResult
    func clickAdjustable() -> Self {
        adjustableSegment.click()
        return self
    }
    
    var addValueButton: XCUIElement {

        window.buttons["Add Value"].firstMatch
    }
    
    @discardableResult
    func addAdjustableVariant(_ text: String) -> Self {
        addValueButton.click()
        
        let lastAdjustableOption = app
            .radioGroups["AdjustableValues"].firstMatch
            .radioButtons.allElementsBoundByIndex.last!
            .descendants(matching: .comboBox).firstMatch
        lastAdjustableOption.click()
        lastAdjustableOption.input(text, pressEnter: false)
        
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
    
    // MARK: - Custom actions
    
    @discardableResult
    func addCustomAction(_ label: String) -> Self {
        let addCustomActionButton = window.buttons["addCustomActionButton"].firstMatch
        
        addCustomActionButton.tap()
        
        let textField = customActionLabelField
        
        textField.tap()
        textField.typeText(label)
        
        return self
    }
    
    lazy var customActionLabelField: XCUIElement =
    window.textFields["customActionTextField"].firstMatch
    
    func customActionLabel() -> String? {
        customActionLabelField.value as? String
    }
    
    // MARK: - Custom description
    
    @discardableResult
    func addCustomDescription(_ label: String, value: String) -> Self {
        let addCustomDescriptionButton = window.buttons["AddCustomDescription"].firstMatch
        
        addCustomDescriptionButton.tap()
        
        customDescriptionLabelField.tap()
        customDescriptionLabelField.typeText(label)
        
        customDescriptionValueField.tap()
        customDescriptionValueField.tap() // TODO: It's a bug
        
        customDescriptionValueField.typeText(value)
        
        return self
    }
    
    lazy var customDescriptionLabelField: XCUIElement =
        window.textFields["CustomDescriptionLabel"].firstMatch
    
    func customDescriptionLabel() -> String? {
        customDescriptionLabelField.value as? String
    }
    
    lazy var customDescriptionValueField: XCUIElement =
    window.textFields["CustomDescriptionValue"].firstMatch
    
    
    func customDescriptionValue() -> String? {
        return customDescriptionValueField.value as? String
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
