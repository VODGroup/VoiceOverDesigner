import Foundation

public enum AccessibilityViewType: String, Codable {
    case element
    case container
}

public protocol AccessibilityView: AnyObject, Equatable, Decodable {
    var label: String { get set }
    var frame: CGRect { get set }
    
    var type: AccessibilityViewType { get }
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


