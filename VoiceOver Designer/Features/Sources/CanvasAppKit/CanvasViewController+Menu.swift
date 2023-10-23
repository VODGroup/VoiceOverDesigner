//
//  CanvasViewController+Menu.swift
//
//
//  Created by Mikhail Rubanov on 23.10.2023.
//

import AppKit

public extension CanvasViewController {
    func makeCanvasMenu() -> NSMenuItem {
        let addImageItem = NSMenuItem(title: NSLocalizedString("Add image", comment: ""), action: #selector(addImageButtonTapped), keyEquivalent: "")
        let duplicateItem = NSMenuItem(title: NSLocalizedString("Duplicate", comment: ""), action: #selector(duplicateMenuSelected), keyEquivalent: "d")
        self.duplicateItem = duplicateItem
        
        let canvasMenuItem = NSMenuItem(title: NSLocalizedString("Canvas", comment: ""), action: nil, keyEquivalent: "")
        let canvasSubMenu = NSMenu(title: NSLocalizedString("Canvas", comment: ""))
        canvasSubMenu.autoenablesItems = false
        canvasSubMenu.addItem(addImageItem)
        canvasSubMenu.addItem(duplicateItem)
        canvasMenuItem.submenu = canvasSubMenu
        
        return canvasMenuItem
    }
}
