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
    
    private static let borderLayerName = "RecentNewDocCollectionViewItem.borderLayer"
    
    private let plusImageView: NSImageView = {
        let image = NSImage(
            systemSymbolName: "plus",
            accessibilityDescription: NSLocalizedString("Create New Project", comment: "Collection view item")
        )
        var symbolConfig = NSImage.SymbolConfiguration(pointSize: 24.0, weight: .regular, scale: .large)
        symbolConfig = symbolConfig.applying(.init(paletteColors: [NSColor.systemGray]))
        let imageView = NSImageView()
        imageView.image = image?.withSymbolConfiguration(symbolConfig)
        imageView.isEditable = false
        return imageView
    }()
    
    private let newTextField: NSTextField = {
        let textField = NSTextField(labelWithString: NSLocalizedString("New Project", comment: "Collection view item"))
        textField.textColor = NSColor.systemGray
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
    
    private var borderLayer: CALayer? {
        view.layer?.sublayers?.first(where: { $0.name == RecentNewDocCollectionViewItem.borderLayerName })
    }
    
    override func loadView() {
        view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            plusImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10.0)
        ])
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        view.layer?.cornerRadius = 15.0
        view.layer?.cornerCurve = .continuous
        addBorderLayer()
    }
    
    private func addBorderLayer() {
        borderLayer?.removeFromSuperlayer()
        
        let layer = CAShapeLayer()
        layer.name = RecentNewDocCollectionViewItem.borderLayerName
        layer.frame = view.bounds
        layer.path = NSBezierPath(roundedRect: view.bounds, xRadius: 15.0, yRadius: 15.0).cgPath
        layer.fillColor = nil
        layer.strokeColor = NSColor.systemGray.cgColor
        layer.lineWidth = 4.0
        layer.lineDashPattern = [5.0, 5.0]
        
        view.layer?.addSublayer(layer)
    }
}

fileprivate extension NSBezierPath {
    
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo: path.move(to: points[0])
            case .lineTo: path.addLine(to: points[0])
            case .curveTo: path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath: path.closeSubpath()
            @unknown default: return CGPath(rect: .zero, transform: nil)
            }
        }
        return path
    }
}
