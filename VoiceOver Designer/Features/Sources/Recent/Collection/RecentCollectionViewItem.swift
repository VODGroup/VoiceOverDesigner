//
//  ProjectCell.swift
//  Projects
//
//  Created by Andrey Plotnikov on 16.07.2022.
//

import Foundation
import AppKit
import Document

class RecentCollectionViewItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier(rawValue: String(describing: RecentCollectionViewItem.self))
    
    let projectCellView = RecentCellView()
    
    override func loadView() {
        view = projectCellView
    }
    
    func configure(image: NSImage?, fileName: String) {
        projectCellView.thumbnail.image = image
        projectCellView.fileNameTextField.stringValue = fileName
        projectCellView.layoutSubtreeIfNeeded()
    }
        
}
