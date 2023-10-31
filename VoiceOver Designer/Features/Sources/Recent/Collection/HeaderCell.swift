//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 04.02.2023.
//

import Foundation
import AppKit

final class HeaderCell: NSView, NSCollectionViewSectionHeaderView {
    lazy var label: NSTextField = {
        let label = NSTextField()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.stringValue = "Header"
        label.textColor = NSColor.labelColor
        label.isBordered = false
        label.isEditable = false
        label.isSelectable = false
        label.backgroundColor = .clear
        return label
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: -16),
            bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
            widthAnchor.constraint(equalTo: label.widthAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let id = NSUserInterfaceItemIdentifier(rawValue: "sectionHeader")
}
