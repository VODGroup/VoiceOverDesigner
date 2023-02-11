import UIKit
import Canvas
import Document

public class VoiceOverLayout {
    private let controls: [any AccessibilityView]
    private let yOffset: CGFloat
    private let scrollView: UIScrollView
    
    public init(
        controls: [any AccessibilityView],
        yOffset: CGFloat,
        scrollView: UIScrollView
    ) {
        self.controls = controls
        self.yOffset = yOffset
        self.scrollView = scrollView
    }
    
    private func accessibilityElement(
        from control: any AccessibilityView,
        at view: UIView
    ) -> Any {
        switch control.cast {
        case .container(let container):
            return VoiceOverContainer(
                container: container,
                accessibilityContainer: container,
                yOffset: yOffset,
                scrollView: scrollView)

        case .element(let element):
            return VoiceOverElement(
                control: element,
                accessibilityContainer: view,
                frame: .relativeToParent(element.frame))
        }
    }
    
    public func accessibilityElements(at view: UIView) -> [Any] {
        controls.map { control in
            accessibilityElement(from: control, at: view)
        }
    }
}
