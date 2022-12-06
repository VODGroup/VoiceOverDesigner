import Foundation

public class A11yContainer: Codable, AccessibilityContainer {
    public init(elements: [A11yDescription], frame: CGRect, label: String) {
        self.elements = elements
        self.frame = frame
        self.label = label
    }
    
    
    public static func ==(lhs: A11yContainer, rhs: A11yContainer) -> Bool {
        lhs.frame == rhs.frame && lhs.elements == rhs.elements && lhs.label == rhs.label
    }
    
    
    public var elements: [A11yDescription]
    public var frame: CGRect
    public var label: String
    public var type: AccessibilityViewType = .container
    
    public static func copy(from model: A11yContainer) -> A11yContainer {
        A11yContainer(
            elements: model.elements.map({ element in
                A11yDescription.copy(from: element)
            }),
            frame: model.frame,
            label: model.label)
    }
}

public enum A11yElement: Codable {
    case description(A11yDescription)
    case container(A11yContainer)
}
extension AccessibilityView {
    public func copy() -> any AccessibilityView {
        if let container = self as? A11yContainer {
            return A11yContainer.copy(from: container)
        } else if let element = self as? A11yDescription {
            return A11yDescription.copy(from: element)
        } else {
            fatalError()
        }
    }
}
