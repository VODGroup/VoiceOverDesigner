//
//  ProjectCellView.swift
//  Projects
//
//  Created by Andrey Plotnikov on 16.07.2022.
//

import Foundation

import AppKit
import Document

class DocumentCellView: NSView {
    
    private lazy var thumbnail: NSImageView = {
        let thumbnail = NSImageView(image: NSImage())
        thumbnail.isEditable = false
        thumbnail.wantsLayer = true
        
        let layer = thumbnail.layer
        layer?.contentsGravity = .resizeAspectFill
        layer?.borderColor = Color.quaternaryLabelColor.cgColor
        layer?.borderWidth = 1
        layer?.cornerRadius = DocumentCornerRadius
        layer?.cornerCurve = .continuous
        
        return thumbnail
    }()
    
    var image: NSImage? {
        didSet {
            thumbnail.layer?.contents = image // image is a NSImage, could also be a CGImage
        }
    }
    
    lazy var fileNameTextField: NSTextField = {
      let view = NSTextField()
        view.isEditable = false
        view.isBordered = false
        view.alignment = .center
        view.backgroundColor = .clear
        view.font = NSFont.preferredFont(forTextStyle: .subheadline)
        view.textColor = Color.labelColor
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
        
        wantsLayer = true
        layer?.backgroundColor = Color.clear.cgColor
    }
    
    override func layout() {
        super.layout()
        
        layer?.shadowPath = CGPath(roundedRect: bounds,
                                   cornerWidth: 15,
                                   cornerHeight: 15,
                                   transform: nil)
    }
    
    func addSubviews() {
        [thumbnail, fileNameTextField].forEach(addSubview(_:))
    }
    
    func addConstraints() {
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        fileNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thumbnail.topAnchor.constraint(equalTo: topAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnail.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            fileNameTextField.topAnchor.constraint(equalTo: thumbnail.bottomAnchor, constant: 8),
            fileNameTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            fileNameTextField.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }
    
    override func isAccessibilityElement() -> Bool {
         true
    }
    
    override func accessibilityRole() -> NSAccessibility.Role? {
        .button
    }
}
