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
    
    lazy var samplesItem: NSToolbarItem = {
        let item = NSToolbarItem.makeSamplesItem()
        item.target = self
        item.action = #selector(showSamplesDidPressed(sender:))
        return item
    }()
    
    lazy var recentItem: NSToolbarItem = {
        let item = NSToolbarItem.makeRecentItem()
        item.target = self
        item.action = #selector(showRecentDidPressed(sender:))
        return item
    }()
    
    @objc private func showRecentDidPressed(sender: NSToolbarItem) {
        actionDelegate?.showRecent(sender)
    }
    
    @objc private func showSamplesDidPressed(sender: NSToolbarItem) {
        actionDelegate?.showSamples(sender)
    }
}

extension PresentationToolbar: NSToolbarDelegate {
    public func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .recentButtonLabel: return recentItem
        case .samplesButtonLabel: return samplesItem
        case .editor: return editorSideBarItem
        default: return nil
        }
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .recentButtonLabel,
            .samplesButtonLabel,
            .flexibleSpace,
            .editor
        ]
    }
}
