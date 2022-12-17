import Foundation
import Document

class VoiceOverContainer: NSObject {
    var container: A11yContainer {
        didSet {
            setup(from: container)
        }
    }
    
    private var yOffset: CGFloat
    private let scale: CGFloat
    
    init(
        container: A11yContainer,
        accessibilityContainer: Any,
        yOffset: CGFloat,
        scale: CGFloat
    ) {
        self.container = container
        self.yOffset = yOffset
        self.scale = scale
        
        super.init()
        
        setup(from: container)
    }
    
    private func setup(from container: A11yContainer) {
        isAccessibilityElement = false
        accessibilityLabel = container.label
        accessibilityFrame = container.frame.offsetBy(dx: 0, dy: yOffset)
        accessibilityElements = container.elements.map({ element in
            let relativeFrame = element.frame.relative(to: container.frame)
            
            return VoiceOverElement(
                control: element,
                accessibilityContainer: self,
                frameInContainerSpace: relativeFrame.scaled(scale))
        })
        accessibilityContainerType = .semanticGroup
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
}
