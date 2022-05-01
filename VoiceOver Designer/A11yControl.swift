//
//  A11yControl.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import AppKit

class A11yControl: CALayer {
    var a11yDescription: A11yDescription? {
        didSet {
            backgroundColor = a11yDescription?.color.cgColor
        }
    }
    
    override var frame: CGRect {
        didSet {
            a11yDescription?.frame = frame
        }
    }
}
