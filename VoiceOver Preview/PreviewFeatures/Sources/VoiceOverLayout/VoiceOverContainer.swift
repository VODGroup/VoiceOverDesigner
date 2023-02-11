import Foundation
import UIKit
import Document

class VoiceOverContainer: NSObject {
    var container: A11yContainer {
        didSet {
            setup(from: container)
        }
    }
    
    private var yOffset: CGFloat
    private let view: UIScrollView
    
    init(
        container: A11yContainer,
        accessibilityContainer: Any,
        yOffset: CGFloat,
        view: UIScrollView
    ) {
        self.container = container
        self.yOffset = yOffset
        self.view = view
        super.init()
        
        setup(from: container)
    }
    
    private func setup(from container: A11yContainer) {
        isAccessibilityElement = false
        accessibilityLabel = container.label
        accessibilityFrame = container.frame.withZeroOrigin()
        
        print("Container \(accessibilityFrame), \(container.label)")
        accessibilityElements = container.elements.map({ element in
            let rect = view.frameInScreenCoordinates(element.frame)
            
            return VoiceOverElement(
                control: element,
                accessibilityContainer: self,
                frameInContainerSpace: rect)
        })
        
        print("")
        accessibilityContainerType = container.containerType.uiKit
        accessibilityNavigationStyle = container.navigationStyle.uiKit
        
        accessibilityViewIsModal = container.isModal
        
        if container.isTabTrait {
            accessibilityTraits.formUnion(.tabBar)
        } else {
            accessibilityTraits.remove(.tabBar)
        }
        
        // TODO: Add enumeration
        // TODO: Add Enumeration to child
    }
}

extension UIScrollView {
    func scaledFrame(_ frame: CGRect) -> CGRect {
        let scale = CGAffineTransform(scaleX: zoomScale, y: zoomScale)
        
        return CGRectApplyAffineTransform(frame, scale)
    }
    
    func frameInScreenCoordinates(_ frame: CGRect) -> CGRect {
        let new = scaledFrame(frame)
        let rect = UIAccessibility.convertToScreenCoordinates(new, in: self)
        
//        print("Convert \(frame) -> \(rect)")
        return rect
    }
}

extension CGRect {
    func relative(to rect: CGRect) -> CGRect {
        
        let origin = CGPoint(
            x: minX - rect.minX,
            y: minY - rect.minY)
        
        return CGRect(
            origin: origin,
            size: size)
    }
    
    func withZeroOrigin() -> CGRect {
        CGRect(origin: .zero, size: size)
    }
}

extension A11yContainer.ContainerType {
    var uiKit: UIAccessibilityContainerType {
        switch self {
        case .landmark: return .landmark
        case .list: return .list
        case .semanticGroup: return .semanticGroup
        }
    }
}

extension A11yContainer.NavigationStyle {
    var uiKit: UIAccessibilityNavigationStyle {
        switch self {
        case .automatic: return .automatic
        case .combined: return .combined
        case .separate: return .separate
        }
    }
}
