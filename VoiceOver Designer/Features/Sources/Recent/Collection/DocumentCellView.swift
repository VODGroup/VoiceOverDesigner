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
    
    enum State {
        case image, loading, needLoading
    }
    
    var state: State? = .needLoading {
        didSet {
            downloadSymbol.alphaValue = 0
            thumbnail.alphaValue = 0
            activityIndicator.alphaValue = 0
            
            switch state {
            case .image:
                thumbnail.alphaValue = 1
            case .loading:
                thumbnail.alphaValue = 0.5
                activityIndicator.alphaValue = 1
                activityIndicator.startAnimation(self)
            case .needLoading:
                thumbnail.alphaValue = 0.5
                downloadSymbol.alphaValue = 1
            case .none:
                break
            }
        }
    }
    
    private lazy var thumbnail: NSImageView = {
        let thumbnail = NSImageView(image: NSImage())
        thumbnail.isEditable = false
        thumbnail.wantsLayer = true
        
        let layer = layer
        layer?.borderColor = Color.quaternaryLabelColor.cgColor
        layer?.borderWidth = 1
//        layer?.contentsGravity = .resizeAspectFill
//        layer?.cornerRadius = DocumentCornerRadius
//        layer?.cornerCurve = .continuous
        
        return thumbnail
    }()
    
    private lazy var downloadSymbol: NSImageView = {
        let imageView = NSImageView()
        imageView.image = NSImage(systemSymbolName: "square.and.arrow.down.on.square",
                                  accessibilityDescription: "Download")
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.alphaValue = 0
        return imageView
    }()
    
    var image: NSImage? {
        didSet {
            thumbnail.image = image
        }
    }
    private lazy var activityIndicator: NSProgressIndicator = {
        let indicator = NSProgressIndicator()
        indicator.isIndeterminate = true
        indicator.alphaValue = 0
        return indicator
    }()
    
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
        [thumbnail, fileNameTextField, downloadSymbol, activityIndicator]
            .forEach(addSubview(_:))
    }
    
    func addConstraints() {
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thumbnail.topAnchor.constraint(equalTo: topAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnail.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        fileNameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fileNameTextField.topAnchor.constraint(equalTo: thumbnail.bottomAnchor, constant: 8),
            fileNameTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            fileNameTextField.widthAnchor.constraint(equalTo: widthAnchor),
        ])
        
        downloadSymbol.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            downloadSymbol.centerXAnchor.constraint(equalTo: centerXAnchor),
            downloadSymbol.centerYAnchor.constraint(equalTo: centerYAnchor),
            downloadSymbol.widthAnchor.constraint(equalToConstant: 100),
            downloadSymbol.heightAnchor.constraint(equalToConstant: 100),
        ])
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: thumbnail.bottomAnchor),
            activityIndicator.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }
    
    override func isAccessibilityElement() -> Bool {
         true
    }
    
    override func accessibilityRole() -> NSAccessibility.Role? {
        .button
    }
}
