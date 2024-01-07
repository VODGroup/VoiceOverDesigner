import CoreGraphics
import Foundation

/// Data layer with hierarchical structure of element
public class Artboard: BaseContainer, Node {
    public static func == (lhs: Artboard, rhs: Artboard) -> Bool {
        return true // Single instance
    }
    
//    let figmaURL: String
    
    public var frames: [Frame] {
        elements.compactMap { element in
            element as? Frame
        }
    }

    public var controlsOutsideOfFrames: [any ArtboardElement] {
        elements.filter { !($0 is Frame) }
    }
    
    public var imageLoader: ImageLoading!
    
    public var isEmpty: Bool {
        elements.isEmpty
    }
    
    public init(elements: [any ArtboardElement] = []) {
        super.init(elements: elements)
    }
}
