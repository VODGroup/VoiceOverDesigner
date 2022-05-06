//
//  A11yControl.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import QuartzCore

public class A11yControl: CALayer {
    
    public var a11yDescription: A11yDescription?
    
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
}
