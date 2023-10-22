import Foundation

public enum AccessibilityViewTypeDto: String, Codable {
    case element
    case container
}

public protocol AccessibilityView: AnyObject, Identifiable, Equatable, Decodable {
    var label: String { get set }
    var frame: CGRect { get set }
    
    var type: AccessibilityViewTypeDto { get }
}

extension AccessibilityView {
    public var cast: AccessibilityViewCast {
        if let container = self as? A11yContainer {
            return .container(container)
        } else if let element = self as? A11yDescription {
            return .element(element)
        } else {
            fatalError()
        }
    }

    public var element: A11yDescription? {
        if let element = self as? A11yDescription {
            return element
        }
        return nil
    }
}

public protocol AccessibilityContainer: AccessibilityView {
    associatedtype Element: AccessibilityElement
    var elements: [Element] { get set }
}

// TODO: Remove if it is unused
public protocol AccessibilityElement: AccessibilityView {
    var isAccessibilityElement: Bool { get set }
    var value: String { get set }
    var hint: String { get set }
    var trait: A11yTraits { get set }
}

public enum AccessibilityViewCast: Equatable, Identifiable {
    case element(_ element: A11yDescription)
    case container(_ container: A11yContainer)

    public var id: UUID {
        switch self {
            case .element(let element):
                return element.id
            case .container(let container):
                return container.id
        }
    }
    public var frame: CGRect {
        switch self {
            case .element(let element):
                return element.frame
            case .container(let container):
                return container.frame
        }
    }

    public var element: A11yDescription? {
        if case let .element(element) = self {
            return element
        }
        return nil
    }
}
