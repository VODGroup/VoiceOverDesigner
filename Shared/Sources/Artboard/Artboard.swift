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
    
    // MARK: Offset
    
    public func offsetCoordinates(toFit sampleArtboard: Artboard) {
        let maxX = sampleArtboard
            .frames
            .map(\.frame.maxX)
            .max() ?? 0
        
        let totalOffset = maxX + sampleArtboard.proposedOffsetBetweenFrames
        
        offset(xOffset: totalOffset)
    }
    
    var proposedOffsetBetweenFrames: CGFloat {
        guard frames.count > 1 else {
            let frameWidth = frames.first?.frame.width ?? 0
            return frameWidth * 0.3 // 30%
        }
        
        let orderedFrame = frames
            .map(\.frame)
            .sorted { lhs, rhs in
                lhs.maxX < rhs.maxX
            }
        let lastFrame = orderedFrame[orderedFrame.count - 1]
        let previousFrame = orderedFrame[orderedFrame.count - 2]
        
        return lastFrame.xDistance(from: previousFrame)
    }
}

extension BaseContainer {
    func offset(xOffset: CGFloat) {
        for element in elements {
            element.frame = element.frame
                .offsetBy(dx: xOffset, dy: 0)
            
            if let container = element as? BaseContainer {
                container.offset(xOffset: xOffset)
            }
        }
    }
}

public extension CGRect {
    func xDistance(from rect: CGRect) -> CGFloat {
        minX - rect.maxX
    }
}
