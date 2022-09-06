//
//  RecentNewDocCollectionViewItem.swift
//  
//
//  Created by Fedor Prokhorov on 06.09.2022.
//

import AppKit
import Foundation

final class RecentNewDocCollectionViewItem: NSCollectionViewItem {
    
    static let identifier = NSUserInterfaceItemIdentifier(rawValue: String(describing: RecentNewDocCollectionViewItem.self))
    
    private let plusImageView: NSImageView = {
        let image = NSImage(
            systemSymbolName: "plus.circle",
            accessibilityDescription: NSLocalizedString("Create New Project", comment: "Collection view item")
        )
        var symbolConfig = NSImage.SymbolConfiguration(pointSize: 24.0, weight: .regular, scale: .large)
        symbolConfig = symbolConfig.applying(.init(paletteColors: [NSColor.white]))
        let imageView = NSImageView()
        imageView.image = image?.withSymbolConfiguration(symbolConfig)
        imageView.isEditable = false
        return imageView
    }()
    
    private let newTextField: NSTextField = {
        let textField = NSTextField(labelWithString: NSLocalizedString("New Project", comment: "Toolbar item"))
        textField.isEditable = false
        textField.isBordered = false
        textField.alignment = .center
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
    
    override func loadView() {
        view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            plusImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
