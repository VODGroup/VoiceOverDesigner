import Foundation

// MARK: - Relation
public protocol Child: AnyObject {
    /// Must be `weak`
    var parent: (any Container)? { get set }
}

public protocol Container: Child {
    var elements: [any ArtboardElement] { get set }
}

public protocol Node: Child, Container {}

// MARK: - Types

public enum ArtboardType: String, Codable {
    case element
    case container
    case frame
    //    case artboard
}

public protocol ArtboardElement: Child, Equatable {
    var id: UUID { get }
    var label: String { get set }
    var frame: CGRect { get set }
    
    var type: ArtboardType { get }
}

public protocol ArtboardContainer: ArtboardElement, Node {}

/// Allows
public protocol InstantiatableContainer {
    init(
        elements: [any ArtboardElement],
        frame: CGRect,
        label: String
    )
}
