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
        settings
            .app.inputText(text: "City")
        clickButtonTrait()
        
        navigator
            .assertFirstCell(text: "City. Button.")
    }
    
    func testExample2() {
        settings
            .app.inputText(text: "Country")
        clickButtonTrait()
        
        navigator
            .assertFirstCell(text: "Country. Button.")
    }
    
    func testDeleteUndoRedo() {
        XCUIApplication().typeKey(XCUIKeyboardKey.delete, modifierFlags: [])
        canvas
            .assertNoElements()
        navigator
            .assertElementsCount(count: 0)
        
        statusBar
            .clickEdit()
            .clickUndoMenu()
        canvas
            .assertHaveElements()
        navigator
            .assertElementsCount(count: 1)
        /*statusBar
            .clickEdit()
            .clickRedoMenu()
         canvas
            .assertNoElements()*/
       
        
    }
    
    func testDragUndoRedo() {
        canvas
            .drag(from: 0.45, to: 0.5)
            .deselect(dx: 0.4, dy: 0.4)
        
        statusBar
            .clickEdit()
            .clickUndoMenu()
        canvas
            .select(dx: 0.41, dy: 0.41)
        
        statusBar
            .clickEdit()
            .clickRedoMenu()
        canvas
            .select(dx: 0.55, dy: 0.55)
        
    }
    
    func testCreateOneElementContainer() {
        //Разворачиваем приложение на весь экран
        statusBar
            .openInFullScreen()
        navigator
            .groupInContainer()
            .assertFirstCell(text: "Container")
        }
    
    func testCreateTwoElementContainer() {
        canvas
            .draw(from: CGVector(dx: 0.4, dy: 0.6),
                  to: CGVector(dx: 0.5, dy: 0.7))
        
        statusBar
            .clickEdit()
            .clickSelectAll()
        
        statusBar
            .openInFullScreen() // TODO: Reduce window's size
        
        navigator
            .groupInContainer()
            .assertFirstCell(text: "Container")
    }
    
    func testChangeSize() {
        canvas
            .deselect(dx: 0.55, dy: 0.55) // same as assert
        
        canvas
            .select(dx: 0.45, dy: 0.45)
            .drag(from: 0.5, to: 0.6)
            .deselect(dx: 0.61, dy: 0.61)
        
        canvas
            .select(dx: 0.55, dy: 0.55) // same as arrange
    }
    
    override func tearDown() {
        closeWindowAndDelete()
        
        super.tearDown()
    }
    
    private func createNewFile() {
        // Создаем новый документ
        statusBar
            .clickFile()
            .clickFileNew()
    }
    
    func drawRectangle() {
        canvas
            .drag(from: 0.4, to: 0.5)
    }
    
    func clickButtonTrait() {
        let window = XCUIApplication().windows.firstMatch
        window.checkBoxes["Button"].click()
    }
    
    func closeWindowAndDelete() {
        statusBar
            .closeWindow()
        settings
            .delete()
    }
}
