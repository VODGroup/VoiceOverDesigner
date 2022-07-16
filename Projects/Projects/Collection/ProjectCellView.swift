//
//  ProjectCellView.swift
//  Projects
//
//  Created by Andrey Plotnikov on 16.07.2022.
//

import Foundation

import AppKit


class ProjectCellView: NSView {
    
    lazy var thumbnail: NSImageView = {
        let view = NSImageView(image: NSImage())
        view.isEditable = false
        return view
    }()
    
    lazy var fileNameTextField: NSTextField = {
      let view = NSTextField()
        view.isEditable = false
        view.isBordered = false
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        [thumbnail, fileNameTextField].forEach(addSubview(_:))
    }
    
    func addConstraints() {
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        fileNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thumbnail.topAnchor.constraint(equalTo: topAnchor),
            thumbnail.bottomAnchor.constraint(equalTo: bottomAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnail.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            fileNameTextField.bottomAnchor.constraint(equalTo: thumbnail.bottomAnchor),
            fileNameTextField.widthAnchor.constraint(equalTo: widthAnchor),
        ])

    }
}
