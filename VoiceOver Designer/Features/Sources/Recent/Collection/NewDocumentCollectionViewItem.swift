//
//  NewDocumentCollectionViewItem.swift
//  
//
//  Created by Fedor Prokhorov on 06.09.2022.
//

import AppKit
import Foundation

let DocumentCornerRadius: CGFloat = 15

final class NewDocumentCollectionViewItem: NSCollectionViewItem {
    
    override func loadView() {
        view = NewDocView()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        view().setup()
    }
    
    func view() -> NewDocView {
        view as! NewDocView
    }
    
    static let identifier = NSUserInterfaceItemIdentifier(
        rawValue: String(describing: NewDocumentCollectionViewItem.self)
    )
}

final class NewDocView: NSView {

    private let borderColor = NSColor.secondaryLabelColor
    
    private lazy var plusImageView: NSImageView = {
        let image = NSImage(
            systemSymbolName: "plus",
            accessibilityDescription: NSLocalizedString("Create New Project", comment: "Collection view item")
        )
        var symbolConfig = NSImage.SymbolConfiguration(pointSize: 24.0, weight: .regular, scale: .large)
        symbolConfig = symbolConfig.applying(.init(paletteColors: [borderColor]))
        let imageView = NSImageView()
        imageView.image = image?.withSymbolConfiguration(symbolConfig)
        imageView.isEditable = false
        return imageView
    }()
    
    private lazy var newTextField: NSTextField = {
        let textField = NSTextField(labelWithString: NSLocalizedString("New Project", comment: "Collection view item"))
        textField.textColor = borderColor
        textField.isEditable = false
        textField.isBordered = false
        textField.alignment = .center
        textField.backgroundColor = .clear
        return textField
    }()
    
    private lazy var stackView: NSStackView = {
        let stackView = NSStackView(views: [plusImageView, newTextField])
        stackView.orientation = .vertical
        stackView.alignment = .centerX
        stackView.distribution = .fill
        stackView.spacing = 15.0
        return stackView
    }()
    
    private var borderLayer: CALayer?
    
    func setup() {
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        layer?.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            plusImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            plusImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -bottomOffset)
        ])
        
        addBorderLayer()
        layer?.cornerRadius = DocumentCornerRadius
        layer?.cornerCurve = .continuous
        
        setAccessibilityEnabled(true)
    }
    
    override func isAccessibilityElement() -> Bool {
        true
    }
    
    override func accessibilityIdentifier() -> String {
        "New"
    }
    
    override func isAccessibilityEnabled() -> Bool {
        true
    }
    
    override func accessibilityRole() -> NSAccessibility.Role? {
        .button
    }
    
    override func accessibilityLabel() -> String? {
        NSLocalizedString("New document", comment: "")
    }
    
    override func layout() {
        super.layout()
        addBorderLayer()
    }
    
    private let bottomOffset: CGFloat = 20
    func addBorderLayer() {
        borderLayer?.removeFromSuperlayer()
        
        let border = CAShapeLayer()
        
        let borderWidth: CGFloat = 2
        
        let frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - bottomOffset)
        let pathFrame = CGRect(x: 0, y: bottomOffset, width: bounds.width, height: bounds.height - bottomOffset)
            .insetBy(dx: borderWidth/2, dy: borderWidth/2)
        
        border.frame = frame
        border.path = CGPath(roundedRect: pathFrame, cornerWidth: DocumentCornerRadius, cornerHeight: DocumentCornerRadius, transform: nil)
        border.fillColor = nil
        border.strokeColor = borderColor.cgColor
        
        border.lineWidth = borderWidth
        border.lineDashPattern = [5.0, 5.0]
        
        layer?.addSublayer(border)
        
        self.borderLayer = border
    }
}
