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
    
    public var defaultOffsetBetweenFrame: CGFloat {
        guard frames.count > 1 else {
            let frameWidth = frames.first?.frame.width ?? 0
            return frameWidth * 1.3 // + 30%
        }
        
        let lastFrame = frames[frames.count - 1].frame
        let previousFrame = frames[frames.count - 2].frame
        
        return previousFrame.minX - lastFrame.maxX
    }
}

extension BaseContainer {
    public func offset(xOffset: CGFloat) {
        for element in elements {
            element.frame = element.frame
                .offsetBy(dx: xOffset, dy: 0)
            
            if let container = element as? BaseContainer {
                container.offset(xOffset: xOffset)
            }
        }
    }
}
