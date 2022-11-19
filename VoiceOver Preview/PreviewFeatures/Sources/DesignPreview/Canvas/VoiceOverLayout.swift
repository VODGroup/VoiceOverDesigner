import UIKit
import Document

class VoiceOverLayout {
    private let controls: [A11yDescription]
    private let container: UIView
    
    init(controls: [A11yDescription], container: UIView) {
        self.controls = controls
        self.container = container
    }
    
    private func accessibilityElement(from control: A11yDescription) -> UIAccessibilityElement {
        VoiceOverElement(control: control, accessibilityContainer: container)
    }
    
    var accessibilityElements: [UIAccessibilityElement] {
        controls.map(accessibilityElement(from:))
    }
}
