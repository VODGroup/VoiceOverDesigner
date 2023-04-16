import Foundation

public enum ArtboardType: String, Codable {
    case element
    case container
    case frame
}

public protocol ArtboardElement: AnyObject, Equatable {
    var label: String { get set }
    var frame: CGRect { get set }
    
    var type: ArtboardType { get }
    
//    var parent: (any ArtboardContainer?) { get }
}

public protocol ArtboardContainer: ArtboardElement {
    var elements: [any ArtboardElement] { get set }
    
    init(
        elements: [any ArtboardElement],
        frame: CGRect,
        label: String
    )
}
