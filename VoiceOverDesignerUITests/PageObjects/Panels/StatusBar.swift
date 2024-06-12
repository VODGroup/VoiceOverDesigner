//
//  StatusBar.swift
//  VoiceOverDesignerUITests
//
//  Created by Mikhail Rubanov on 12.06.2024.
//

import XCTest

class StatusBar: ProjectPanel {
    var statusBar: XCUIElement { app.menuBars.firstMatch }
    
    var editMenu: XCUIElement { statusBar.menuBarItems["Edit"].firstMatch }
    
    var selectAllMenu: XCUIElement { statusBar.menuItems["Select All"].firstMatch }
    
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
    func openInFullScreen() -> Self {
        app.buttons[XCUIIdentifierFullScreenWindow].click()
        
        return self
    }
}
