import Foundation
import Document

class VoiceOverContainer: NSObject {
    var container: A11yContainer {
        didSet {
            setup(from: container)
        }
    }
    
    private let scrollView: ScrollViewConverable
    
    init(
        container: A11yContainer,
        accessibilityContainer: Any,
        scrollView: ScrollViewConverable
    ) {
        self.container = container
        self.scrollView = scrollView
        super.init()
        
        setup(from: container)
    }
    
    private func setup(from container: A11yContainer) {
        let containerFrame = scrollView.frameInScreenCoordinates(container.frame)
        
        isAccessibilityElement = false
        accessibilityLabel = container.label
        accessibilityFrame = containerFrame
        
        print("Container \(accessibilityFrame), \(container.label)")
        accessibilityElements = container.elements.compactMap({ element in
            guard let element = element as? A11yDescription // TODO: Add support for different type
            else { return nil }
            
            let rect = scrollView
                .frameInScreenCoordinates(element.frame)
                .relative(to: containerFrame)
            
            let a11yElement = VoiceOverElement(
                control: element,
                accessibilityContainer: self,
                frame: .relativeToParent(rect))
            
            return a11yElement
        })

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

import UIKit
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
