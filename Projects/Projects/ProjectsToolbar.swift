//
//  ProjectsToolbar.swift
//  Projects
//
//  Created by Andrey Plotnikov on 16.07.2022.
//

import Foundation
import AppKit

public class ProjectsToolbar: NSToolbar {
    public override init(identifier: NSToolbar.Identifier) {
        super.init(identifier: identifier)
        delegate = self
    }
    
    public lazy var addButton: NSButton = {
        let button = NSButton(frame: .zero)
        button.image = NSImage(systemSymbolName: "plus", accessibilityDescription: "Create New Project")
        button.isBordered = false
        return button
    }()
    
}



extension NSToolbarItem.Identifier {
    static let createNewProject = NSToolbarItem.Identifier(rawValue: "CreateNewProject")
}

extension ProjectsToolbar: NSToolbarDelegate {
    public func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .createNewProject:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.view = addButton
            return item
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
