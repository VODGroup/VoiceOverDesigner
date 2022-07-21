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
            accessibilityElement(from: control)
        }
    }
    
    private func accessibilityElement(from control: A11yDescription) {
        isAccessibilityElement = true
        accessibilityLabel = control.label
        accessibilityValue = control.value
        accessibilityHint = control.hint
        accessibilityFrame = control.frame
        accessibilityTraits = control.trait.accessibilityTrait
    }
    
    override func accessibilityIncrement() {
        control.accessibilityIncrement()
        accessibilityElement(from: control)
    }
    
    override func accessibilityDecrement() {
        control.accesibilityDecrement()
        accessibilityElement(from: control)
    }
}
