import Foundation
import Document
import UIKit

enum ElementFrame {
    case screenCoordinates(CGRect)
    case relativeToParent(CGRect)
}

class VoiceOverElement: UIAccessibilityElement {
    var control: A11yDescription {
        didSet {
            setup(from: control)
        }
    }
    
    var frame: ElementFrame
    
    init(
        control: A11yDescription,
        accessibilityContainer: Any,
        frame: ElementFrame
    ) {
        self.control = control
        self.frame = frame
        super.init(accessibilityContainer: accessibilityContainer)
        setup(from: control)
    }
    
    private func setup(from model: A11yDescription) {
        isAccessibilityElement = true
        accessibilityLabel = model.label
        accessibilityValue = model.value
        accessibilityHint = model.hint
        accessibilityTraits = model.trait.accessibilityTrait
        
        switch frame {
        case .screenCoordinates(let frame):
            accessibilityFrame = frame
        case .relativeToParent(let frame):
            accessibilityFrameInContainerSpace = frame
        }
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
        set {}
    }
}


@available(iOS 14.0, *)
extension VoiceOverElement: AXCustomContentProvider {
    var accessibilityCustomContent: [AXCustomContent]! {
        get {
            control.customDescriptions.descriptions.map {
                AXCustomContent(label: $0.label, value: $0.value)
            }
        }
        set { }
    }
}
