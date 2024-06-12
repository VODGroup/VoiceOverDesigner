//
//  StatusBar.swift
//  VoiceOverDesignerUITests
//
//  Created by Mikhail Rubanov on 12.06.2024.
//

import XCTest

class StatusBar: ProjectPanel {
    
    var statusBar: XCUIElement { app.menuBars.firstMatch }
    
    var fileMenu: XCUIElement {statusBar.menuBarItems["File"].firstMatch}
    
    var editMenu: XCUIElement { statusBar.menuBarItems["Edit"].firstMatch }
    
    var fileNewMenu: XCUIElement {statusBar.menuItems["New"].firstMatch}
    
    var selectAllMenu: XCUIElement { statusBar.menuItems["Select All"].firstMatch }
    
    var undoMenu: XCUIElement {statusBar.menuItems["Undo"].firstMatch}
    
    var redoMenu: XCUIElement {statusBar.menuItems["Redo"].firstMatch}
    
    @discardableResult
    func clickFile() -> Self {
        fileMenu.click()
        
        return self
    }
    
    @discardableResult
    func clickFileNew() -> Self {
        fileNewMenu.click()
        
        return self
    }
    
    @discardableResult
    func clickEdit() -> Self {
        editMenu.click()
        
        return self
    }
    
    @discardableResult
    func clickSelectAll() -> Self {
        selectAllMenu.click()
        
        return self
    }
    
    @discardableResult
    func clickUndoMenu() -> Self {
        undoMenu.click()
        
        return self
    }
    
    @discardableResult
    func clickRedoMenu() -> Self {
        redoMenu.click()
        
        return self
    }

    @discardableResult
    func openInFullScreen() -> Self {
        app.buttons[XCUIIdentifierFullScreenWindow].click()
        
        return self
    }
}
