import UIKit
import Document

class VoiceOverLayout {
    private let controls: [any AccessibilityView]
    private let container: UIView
    private let yOffset: CGFloat
    
    init(
        controls: [any AccessibilityView],
        container: UIView,
        yOffset: CGFloat
    ) {
        self.controls = controls
        self.container = container
        self.yOffset = yOffset
    }
    
    private func accessibilityElement(
        from control: any AccessibilityView
    ) -> Any {
        switch control.cast {
        case .container(let container):
            return VoiceOverContainer(
                container: container,
                accessibilityContainer: container,
                yOffset: yOffset)
            
        case .element(let element):
            return VoiceOverElement(
                control: element,
                accessibilityContainer: container,
                frameInContainerSpace: element.frame)
        }
    }
    
    var accessibilityElements: [Any] {
        controls.map(accessibilityElement(from:))
    }
}
