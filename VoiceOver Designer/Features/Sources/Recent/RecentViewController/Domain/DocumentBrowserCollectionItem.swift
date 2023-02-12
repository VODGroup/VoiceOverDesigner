//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 12.02.2023.
//

import Foundation


public struct DocumentRenameAction {
    let name: String
    let keyEquivalent: String
    let action: (String) throws -> ()
    
    
    func callAsFunction(_ value: String) throws {
        try action(value)
    }
}

public struct DocumentBrowserCollectionItem {
    let content: Content
    
    let menu: [MenuAction]
    let renameAction: DocumentRenameAction?
    
    init(
        content: Content,
        menu: [MenuAction] = [],
        renameAction: DocumentRenameAction? = nil) {
        self.content = content
        self.menu = menu
        self.renameAction = renameAction
    }
    
    
    
    struct MenuAction {
        let name: String
        let keyEquivalent: String
        let action: () -> Void
        
        var item: MenuItem {
            MenuItem(title: name, keyEquivalent: keyEquivalent, action: action)
        }
    }
        
    /// Type of cell in collection view
    public enum Content {
        /// Regular (existing) document item
        case document(URL)
        /// Add new document item
        case newDocument
        /// Downloadable sample
        case sample(DownloadableDocument)
    }
    
}

