//
//  A11yControl.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import QuartzCore

public class A11yControl: CALayer {
    
    public var a11yDescription: A11yDescription?
    
    public lazy var label: CATextLayer? = {
        let label = CATextLayer()
        label.string = a11yDescription?.label
        label.fontSize = 10
        label.foregroundColor = Color.white.cgColor
        label.backgroundColor = Color.systemGray.withAlphaComponent(0.7).cgColor
        let size = label.preferredFrameSize()
        label.frame = .init(origin: .zero, size: size).offsetBy(dx: 0, dy: -size.height - 1)
        return label
    }()
    
    override public func layoutSublayers() {
        if let size = label?.preferredFrameSize() {
            label?.frame = .init(origin: .zero, size: size).offsetBy(dx: 0, dy: -size.height - 1)
        }
    }
    
    public func updateColor() {
        backgroundColor = a11yDescription?.color.cgColor
    }
    
    public override var frame: CGRect {
        didSet {
            a11yDescription?.frame = frame
        }
    }
    
    public var isHiglighted: Bool = false {
        didSet {
            backgroundColor = backgroundColor?.copy(alpha: isHiglighted ? 0.75: 0.5) 
        }
    }
    
    public var isSelected: Bool = false {
        didSet {
            borderWidth = isSelected ? 4 : 0
            borderColor = backgroundColor?.copy(alpha: 1)
            cornerRadius = isSelected ? 10 : 0
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
