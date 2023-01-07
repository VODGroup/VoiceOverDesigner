//
//  RecentNewDocCollectionViewItem.swift
//  
//
//  Created by Fedor Prokhorov on 06.09.2022.
//

import AppKit
import Foundation

let DocumentCornerRadius: CGFloat = 15

final class RecentNewDocCollectionViewItem: NSCollectionViewItem {
    
    static let identifier = NSUserInterfaceItemIdentifier(rawValue: String(describing: RecentNewDocCollectionViewItem.self))
    
    private static let borderLayerName = "RecentNewDocCollectionViewItem.borderLayer"
    private let tintColor = NSColor.secondaryLabelColor
    
    private lazy var plusImageView: NSImageView = {
        let image = NSImage(
            systemSymbolName: "plus",
            accessibilityDescription: NSLocalizedString("Create New Project", comment: "Collection view item")
        )
        var symbolConfig = NSImage.SymbolConfiguration(pointSize: 24.0, weight: .regular, scale: .large)
        symbolConfig = symbolConfig.applying(.init(paletteColors: [tintColor]))
        let imageView = NSImageView()
        imageView.image = image?.withSymbolConfiguration(symbolConfig)
        imageView.isEditable = false
        return imageView
    }()
    
    private lazy var newTextField: NSTextField = {
        let textField = NSTextField(labelWithString: NSLocalizedString("New Project", comment: "Collection view item"))
        textField.textColor = tintColor
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
    
    override func loadView() {
        view = NSView()
        view.setAccessibilityIdentifier("New")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer?.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            plusImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -bottomOffset)
        ])
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        view.layer?.cornerRadius = DocumentCornerRadius
        view.layer?.cornerCurve = .continuous
        addBorderLayer()
    }
    
    private let bottomOffset: CGFloat = 20
    private func addBorderLayer() {
        borderLayer?.removeFromSuperlayer()
        
        let layer = CAShapeLayer()
        layer.name = RecentNewDocCollectionViewItem.borderLayerName
        
        let borderWidth: CGFloat = 2
        
        let frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - bottomOffset)
        let pathFrame = CGRect(x: 0, y: bottomOffset, width: view.bounds.width, height: view.bounds.height - bottomOffset)
            .insetBy(dx: borderWidth/2, dy: borderWidth/2)
        
        layer.frame = frame
        layer.path = CGPath(roundedRect: pathFrame, cornerWidth: DocumentCornerRadius, cornerHeight: DocumentCornerRadius, transform: nil)
        layer.fillColor = nil
        layer.strokeColor = tintColor.cgColor
        
        layer.lineWidth = borderWidth
        layer.lineDashPattern = [5.0, 5.0]
        
        view.layer?.addSublayer(layer)
        
        self.borderLayer = layer
    }
}
