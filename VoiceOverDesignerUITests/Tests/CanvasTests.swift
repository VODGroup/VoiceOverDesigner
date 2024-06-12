//
//  SettingsTestsAuto.swift
//  VoiceOverDesignerUITests
//
//  Created by Mikhail Rubanov on 11.04.2024.
//

import XCTest

final class CanvasTests: DesignerTests {

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app.launch()
        
        createNewFile()
        drawRectangle()
    }

    func testExample() {
        input(text: "City")
        clickButtonTrait()
        
        assertNavigatorFirstCell(text: "City. Button.")
    }
    
    func testExample2() {
        input(text: "Country")
        clickButtonTrait()
        
        assertNavigatorFirstCell(text: "Country. Button.")
    }
    
    func testDeleteUndoRedo() {
        XCUIApplication().typeKey(XCUIKeyboardKey.delete, modifierFlags: [])
        XCTAssertTrue(app.staticTexts["Add your screenshot"].exists)
        assertNavigatorElements(count: 0)
        
        let menuBarsQuery = app.menuBars
        let editMenuBarItem = menuBarsQuery.menuBarItems["Edit"]
        editMenuBarItem.click()
        menuBarsQuery.menuItems["Undo"].click()
        XCTAssertFalse(app.staticTexts["Add your screenshot"].exists)
        assertNavigatorElements(count: 1)
        //editMenuBarItem.click()
        //menuBarsQuery.menuItems["Redo"].click()
        //XCTAssertTrue(app.staticTexts["Add your screenshot"].exists)
        
    }
    
    func testDragUndoRedo() {
        let from = CGVector(dx: 0.45, dy: 0.45)
        let to = CGVector(dx: 0.5, dy: 0.5)
        
        let window = app.windows.firstMatch
        let start   = window.coordinate(withNormalizedOffset: from)
        let finish  = window.coordinate(withNormalizedOffset: to)
        
        start.press(forDuration: 0.01, thenDragTo: finish)
        
        let menuBarsQuery = app.menuBars
        let editMenuBarItem = menuBarsQuery.menuBarItems["Edit"]
        editMenuBarItem.click()
        menuBarsQuery.menuItems["Undo"].click()
        editMenuBarItem.click()
        menuBarsQuery.menuItems["Redo"].click()
        
    }
    
    func testCreateOneElementContainer() {
        //Разворачиваем приложение на весь экран
        XCUIApplication().buttons[XCUIIdentifierFullScreenWindow].click()
        XCUIApplication().buttons["Group in Container"].click()
        
        //assertLabel(text: "Container")
        }
    
    func testCreateTwoElementContainer() {
        
        let from = CGVector(dx: 0.4, dy: 0.6)
        let to = CGVector(dx: 0.5, dy: 0.7)
        
        let window = app.windows.firstMatch
        let start   = window.coordinate(withNormalizedOffset: from)
        let finish  = window.coordinate(withNormalizedOffset: to)
        
        start.press(forDuration: 0.01, thenDragTo: finish)
        
        let menuBarsQuery = app.menuBars
        let editMenuBarItem = menuBarsQuery.menuBarItems["Edit"]
        editMenuBarItem.click()
        menuBarsQuery.menuItems["Select All"].click()
        //Разворачиваем приложение на весь экран
        XCUIApplication().buttons[XCUIIdentifierFullScreenWindow].click()
        XCUIApplication().buttons["Group in Container"].click()
        
        //assertLabel(text: "Container")
    }
    
    func testChangeSize() {
        canvas
            .deselect(dx: 0.55, dy: 0.55) // same as assert
        
        canvas
            .select(dx: 0.45, dy: 0.45)
            .drag(from: 0.5, to: 0.6)
            .deselect(dx: 0.61, dy: 0.61)
        
        canvas
            .select(dx: 0.55, dy: 0.55) // same as range
    }
    
    override func tearDown() {
        closeWindowAndDelete()
        
        super.tearDown()
    }
    
    private func createNewFile() {
        // Создаем новый документ
        let menuBarsQuery = app.menuBars
        
        let fileMenu = menuBarsQuery.menuBarItems["File"]
        fileMenu.click()
        
        let fileNewMenu = menuBarsQuery.menuItems["New"]
        fileNewMenu.click()
    }
    
    func drawRectangle() {
        canvas.drag(from: 0.4, to: 0.5)
    }
    
    func input(text: String) {
        let window = XCUIApplication().windows.firstMatch
        
        let labelComboBox = window.comboBoxes["LabelTextField"]
        labelComboBox.click()
        labelComboBox.typeText(text)
        labelComboBox.typeKey(XCUIKeyboardKey.enter, modifierFlags: [])
    }
    
    func clickButtonTrait() {
        let window = XCUIApplication().windows.firstMatch
        window.checkBoxes["Button"].click()
    }
    
    func assertNavigatorFirstCell(text: String, file: StaticString = #file, line: UInt = #line) {
        let window = XCUIApplication().windows.firstMatch
        
        let navigator = window.outlines.firstMatch
        let actualText = navigator.cells.staticTexts.firstMatch.value as? String

        XCTAssertEqual(actualText, text, file: file, line: line)
    }
    
    func assertNavigatorElements(count: Int, file: StaticString = #file, line: UInt = #line) {
        let window = XCUIApplication().windows.firstMatch
        
        let navigator = window.outlines.firstMatch
        let cellsCount = navigator.cells.count
        
        XCTAssertEqual(cellsCount, count, file: file, line: line)
    }
    
    func closeWindowAndDelete() {
        let window = XCUIApplication().windows.firstMatch
        
        window.buttons[XCUIIdentifierCloseWindow].click()
        window.sheets.buttons["Delete"].click()
    }

}
