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
        NSToolbarItem.editorSideBarItem()
    }()
    
    lazy var documentsItem: NSToolbarItem = {
        let item = NSToolbarItem.makeDocumentsItem()
        item.target = self
        item.action = #selector(showRecentDidPressed(sender:))
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
