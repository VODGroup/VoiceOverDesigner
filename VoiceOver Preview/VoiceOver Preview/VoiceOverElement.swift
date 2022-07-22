//
//  VoiceOverElement.swift
//  VoiceOver Preview
//
//  Created by Andrey Plotnikov on 21.07.2022.
//

import Foundation
import Document
import UIKit

class VoiceOverElement: UIAccessibilityElement {
    var control: A11yDescription! {
        didSet {
            setup(from: control)
        }
    }
    
    private func setup(from model: A11yDescription) {
        isAccessibilityElement = true
        accessibilityLabel = model.label
        accessibilityValue = model.value
        accessibilityHint = model.hint
        accessibilityFrame = model.frame
        accessibilityTraits = model.trait.accessibilityTrait
    }
    
    override func accessibilityIncrement() {
        control.accessibilityIncrement()
        setup(from: control)
    }
    
    override func accessibilityDecrement() {
        control.accessibilityDecrement()
        setup(from: control)
    }
}
