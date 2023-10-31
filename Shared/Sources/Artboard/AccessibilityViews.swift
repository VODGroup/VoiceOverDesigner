import Foundation

public enum ArtboardType: String, Codable {
    case element
    case container
    case frame
}

public protocol ArtboardElement: AnyObject, Equatable {
    var id: UUID { get }
    var label: String { get set }
    var frame: CGRect { get set }
    
    var type: ArtboardType { get }
    
    /// Had to be `weak`
    var parent: (any ArtboardContainer)? { get set }
}

public protocol ArtboardContainer: ArtboardElement {
    var elements: [any ArtboardElement] { get set }
}

/// Allows
public protocol InstantiatableContainer {
    init(
        elements: [any ArtboardElement],
        frame: CGRect,
        label: String
    )
}
