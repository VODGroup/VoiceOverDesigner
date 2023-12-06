import Foundation

public enum ArtboardType: String, Codable {
    case element
    case container
    case frame
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
