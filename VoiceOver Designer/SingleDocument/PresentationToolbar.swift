//
//  PresentationToolbar.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 23.10.2023.
//

import AppKit

class PresentationToolbar: NSToolbar {
    weak var actionDelegate: ProjectRouterDelegate?
    
    init(actionDelegate: ProjectRouterDelegate?) {
        self.actionDelegate = actionDelegate
        
        super.init(identifier: NSToolbar.Identifier("Presentation"))
        
        delegate = self
    }
    
    lazy var editorSideBarItem: NSToolbarItem = {
        let item = NSToolbarItem(itemIdentifier: .editor)
        item.label = NSLocalizedString("Edit", comment: "")
        item.isBordered = true
        item.image = NSImage(systemSymbolName: "highlighter",
                             accessibilityDescription: "Open editor mode")!
        item.toolTip = NSLocalizedString("Open editor mode", comment: "")
        
        return item
    }()
    
    lazy var documentsItem: NSToolbarItem = {
        let item = NSToolbarItem(itemIdentifier: .documentsButtonLabel)
        item.label = NSLocalizedString("Recent", comment: "")
        item.target = self
        item.action = #selector(showRecentDidPressed(sender:))
        item.isBordered = true
        item.image = NSImage(systemSymbolName: "rectangle.grid.3x2",
                             accessibilityDescription: "Show recent documents")!
        item.toolTip = NSLocalizedString("Go to my documents", comment: "")
        item.isNavigational = true
        return item
    }()
    
    @objc private func showRecentDidPressed(sender: NSToolbarItem) {
        actionDelegate?.showRecent()
    }
}

extension PresentationToolbar: NSToolbarDelegate {
    public func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .documentsButtonLabel: return documentsItem
        case .editor: return editorSideBarItem
        default: return nil
        }
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .documentsButtonLabel,
            .flexibleSpace,
            .editor
        ]
    }
}
