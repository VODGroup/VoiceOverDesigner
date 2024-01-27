//
//  ToolbarItems.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 23.10.2023.
//

import AppKit

extension NSToolbarItem {
    static func makeRecentItem() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .recentButtonLabel)
        item.label = NSLocalizedString("Recent", comment: "")
        
        item.isBordered = true
        item.image = NSImage(systemSymbolName: "clock",
                             accessibilityDescription: "Show recent documents")!
        item.toolTip = NSLocalizedString("Go to My documents", comment: "")
        item.isNavigational = true
        return item
    }
    
    static func makeSamplesItem() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .samplesButtonLabel)
        item.label = NSLocalizedString("Samples", comment: "")
        
        item.isBordered = true
        item.image = NSImage(systemSymbolName: "trophy",
                             accessibilityDescription: "Show sample documents")!
        item.toolTip = NSLocalizedString("Go to Samples", comment: "")
        item.isNavigational = true
        return item
    }
    
    static func presentationSideBarItem() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .presentation)
        item.label = NSLocalizedString("Presentation", comment: "")
        item.isBordered = true
        item.image = NSImage(systemSymbolName: "play.fill",
                             accessibilityDescription: "Open presentation mode")!
        item.toolTip = NSLocalizedString("Open presentation mode", comment: "")
        return item
    }
    
    static func editorSideBarItem() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .editor)
        item.label = NSLocalizedString("Edit", comment: "")
        item.isBordered = true
        item.image = NSImage(systemSymbolName: "highlighter",
                             accessibilityDescription: "Open editor mode")!
        item.toolTip = NSLocalizedString("Open editor mode", comment: "")
        
        return item
    }
    
    @available(macOS, obsoleted: 14.0)
    static func trailingSideBarItem() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .trailingSidebar)
        item.label = NSLocalizedString("Inspector", comment: "")
        item.isBordered = true
        item.image = NSImage(systemSymbolName: "sidebar.trailing",
                             accessibilityDescription: "Close inspector sidebar")!
        item.toolTip = NSLocalizedString("Close inspector sidebar", comment: "")
        return item
    }
}

extension NSToolbarItem.Identifier {
    static let recentButtonLabel = NSToolbarItem.Identifier(rawValue: "RecentButtonLabel")
    static let samplesButtonLabel = NSToolbarItem.Identifier(rawValue: "SamplesButtonLabel")
    
    static let trailingSidebar = NSToolbarItem.Identifier(rawValue: "TrailingSidebar")
    static let presentation = NSToolbarItem.Identifier(rawValue: "Presentation")
    static let editor = NSToolbarItem.Identifier(rawValue: "Editor")
    static let leadingSidebar = NSToolbarItem.Identifier(rawValue: "LeadingSidebar")
    static let itemListTrackingSeparator = NSToolbarItem.Identifier("ItemListTrackingSeparator")
    static let shareDocument = NSToolbarItem.Identifier("ShareDocument")
}

extension NSToolbar {
    
    @discardableResult
    func removeItem(identifier: NSToolbarItem.Identifier) -> Int? {
        if let index = items
            .firstIndex(where: { $0.itemIdentifier == identifier }) {
            removeItem(at: index)
            return index
        }
        return nil
    }
}
