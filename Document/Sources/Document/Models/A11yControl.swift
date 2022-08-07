//
//  A11yControl.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import QuartzCore

public class A11yControl: CALayer {
    
    struct Config {
        let selectedBorderWidth: CGFloat = 4
        let selectedCornerRadius: CGFloat = 10
        
        let highlightedAlpha: CGFloat = 0.75
        let normalAlpha: CGFloat = 0.5
        let normalCornerRadius: CGFloat = 0
        
        let fontSize: CGFloat = 10
    }
    
    private let config = Config()
    
    public var a11yDescription: A11yDescription?
    
    public lazy var label: CATextLayer? = {
        let label = CATextLayer()
        label.string = a11yDescription?.label
        label.fontSize = config.fontSize
        label.foregroundColor = Color.white.cgColor
        label.backgroundColor = Color.systemGray.withAlphaComponent(0.7).cgColor
        let size = label.preferredFrameSize()
        label.frame = .init(origin: .zero, size: size).offsetBy(dx: 0, dy: -size.height - 1)
        return label
    }()
    
    override public func layoutSublayers() {
        if let size = label?.preferredFrameSize() {
            label?.frame = .init(origin: .zero, size: size)
                .offsetBy(dx: 0, dy: -size.height - 1)
        }
    }
    
    public func updateColor() {
        backgroundColor = a11yDescription?.color.cgColor
        borderColor = a11yDescription?.color.cgColor.copy(alpha: 1)
    }
    
    public override var frame: CGRect {
        didSet {
            a11yDescription?.frame = frame
        }
    }
    
    public var isHiglighted: Bool = false {
        didSet {
            let alpha = isHiglighted
            ? config.highlightedAlpha
            : config.normalAlpha
            
            backgroundColor = backgroundColor?.copy(alpha: alpha)
        }
    }
    
    public var isSelected: Bool = false {
        didSet {
            borderWidth = isSelected ? config.selectedBorderWidth : 0
            borderColor = backgroundColor?.copy(alpha: 1)
            cornerRadius = isSelected ? config.selectedCornerRadius : config.normalCornerRadius
            if #available(macOS 10.15, *) {
                cornerCurve = .continuous
            }
        }
    }
    
    public func addLabel() {
        if let label = label {
            addSublayer(label)
        }
    }
    
    public func removeLabel() {
        label?.removeFromSuperlayer()
    }
}

public extension A11yControl {
    static func copy(from model: A11yDescription) -> A11yControl {
        let control = A11yControl()
        control.a11yDescription = model
        control.backgroundColor = model.color.cgColor
        control.frame = model.frame
        return control
    }
}
