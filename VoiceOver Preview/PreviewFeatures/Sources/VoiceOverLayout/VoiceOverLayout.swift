import UIKit
import Canvas
import Document

public class VoiceOverLayout {
    private let controls: [any ArtboardElement]
    private let scrollView: ScrollViewConverable
    
    public init(
        controls: [any ArtboardElement],
        scrollView: ScrollViewConverable
    ) {
        self.controls = controls
        self.scrollView = scrollView
    }
    
    private func accessibilityElement(
        from control: any ArtboardElement,
        at view: UIView
    ) -> Any {
        switch control.cast {
        case .container(let container):
            return VoiceOverContainer(
                container: container,
                accessibilityContainer: container,
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
    
    public func updateContainers(in accessibilityElements: [Any]) {
        for (index, element) in accessibilityElements.enumerated() {
            if let container = element as? VoiceOverContainer {
                let control = controls[index]
                let containerFrame = scrollView.frameInScreenCoordinates(control.frame)
                container.accessibilityFrame = containerFrame
            }
        }
    }
}
