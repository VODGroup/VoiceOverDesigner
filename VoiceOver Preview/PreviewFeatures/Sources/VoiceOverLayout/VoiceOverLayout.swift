import UIKit
import Canvas
import Document

public class VoiceOverLayout {
    private let controls: [any AccessibilityView]
    private let container: UIView
    private let yOffset: CGFloat
    private let scale: CGFloat
    
    public init(
        controls: [any AccessibilityView],
        container: UIView,
        yOffset: CGFloat,
        scale: CGFloat
    ) {
        self.controls = controls
        self.container = container
        self.yOffset = yOffset
        self.scale = scale
    }
    
    private func accessibilityElement(
        from control: any AccessibilityView
    ) -> Any {
        switch control.cast {
        case .container(let container):
            return VoiceOverContainer(
                container: container,
                accessibilityContainer: container,
                yOffset: yOffset,
                scale: scale)
            
        case .element(let element):
            return VoiceOverElement(
                control: element,
                accessibilityContainer: container,
                frameInContainerSpace: element.frame.scaled(scale))
        }
    }
    
    public var accessibilityElements: [Any] {
        controls.map(accessibilityElement(from:))
    }
}
