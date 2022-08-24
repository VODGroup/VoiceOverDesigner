//
//  VoiceOverElement.swift
//  VoiceOver Preview
//
//  Created by Andrey Plotnikov on 21.07.2022.
//

import Foundation
import Document
import UIKit

class VoiceOverElement: UIAccessibilityElement, AXCustomContentProvider {
    var control: A11yDescription {
        didSet {
            setup(from: control)
        }
    }
    
    init(control: A11yDescription, accessibilityContainer: Any) {
        self.control = control
        super.init(accessibilityContainer: accessibilityContainer)
        setup(from: control)
    }
    
    private func setup(from model: A11yDescription) {
        isAccessibilityElement = true
        accessibilityLabel = model.label
        accessibilityValue = model.value
        accessibilityHint = model.hint
        accessibilityFrameInContainerSpace = model.frame
        accessibilityTraits = model.trait.accessibilityTrait
        accessibilityCustomContent = model.customDescriptions.descriptions.map({AXCustomContent(label: $0.label, value: $0.value)})
    }
    
    override func accessibilityIncrement() {
        control.accessibilityIncrement()
        setup(from: control)
    }
    
    override func accessibilityDecrement() {
        control.accessibilityDecrement()
        setup(from: control)
    }
    
    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            control.customActions.names.map({
                UIAccessibilityCustomAction(name: $0, actionHandler: { _ in
                    true
                })
            })
        }
        set {
            
        }
    }
    
}


