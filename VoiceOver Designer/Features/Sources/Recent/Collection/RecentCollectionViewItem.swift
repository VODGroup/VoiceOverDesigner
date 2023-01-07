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
    
    func configure(fileName: String) {
        projectCellView.fileNameTextField.stringValue = fileName
        projectCellView.layoutSubtreeIfNeeded()
    }

    var image: NSImage? {
        didSet {
            projectCellView.image = image
        }
    }
    
    var expectedImageSize: CGSize {
        CGSize(width: 125,
               height: 280)
    }
}
