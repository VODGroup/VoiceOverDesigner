//
//  ProjectCell.swift
//  Projects
//
//  Created by Andrey Plotnikov on 16.07.2022.
//

import Foundation
import AppKit
import Document

class ProjectCollectionViewItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier(rawValue: String(describing: ProjectCollectionViewItem.self))
    
    let projectCellView = ProjectCellView()
    
    override func loadView() {
        view = projectCellView
    }
    
    func configure(image: NSImage?, fileName: String) {
        projectCellView.thumbnail.image = image
        projectCellView.fileNameTextField.stringValue = fileName
        projectCellView.layoutSubtreeIfNeeded()
    }
        
}
