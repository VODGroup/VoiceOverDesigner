//
//  ProjectsToolbar.swift
//  Projects
//
//  Created by Andrey Plotnikov on 16.07.2022.
//

import Foundation
import AppKit

public class RecentToolbar: NSToolbar {
    public override init(identifier: NSToolbar.Identifier) {
        super.init(identifier: identifier)
        delegate = self
    }
    
    public lazy var addButton: NSToolbarItem = {
        let item = NSToolbarItem(itemIdentifier: .createNewProject)
        item.image = NSImage(systemSymbolName: "plus",
                             accessibilityDescription: NSLocalizedString("Create New Project",
                                                                         comment: "Toolbar item"))
        item.label = NSLocalizedString("New", comment: "Toolbar item")
        item.paletteLabel = NSLocalizedString("New Project", comment: "Toolbar item")
        item.toolTip = NSLocalizedString("Create new Project", comment: "Toolbar item")
        return item
    }()
}

extension NSToolbarItem.Identifier {
    static let createNewProject = NSToolbarItem.Identifier(rawValue: "CreateNewProject")
}

extension RecentToolbar: NSToolbarDelegate {
    public func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .createNewProject:
            return addButton
        default:
            return nil
        }
    }

    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.createNewProject]
    }

    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.createNewProject]
    }
}
