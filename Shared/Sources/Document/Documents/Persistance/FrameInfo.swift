import CoreGraphics

// If feature we can wrap document's data in frame and make array of frames
//public struct Frame {

//    public var controls: [any AccessibilityView] = []
//    public var image: Image?
//    public var frameInfo: FrameInfo
//}

import Foundation

/// Data transfer object that represents file structure
public struct FrameInfo: Codable {
    public var id: UUID
    public var imageScale: CGFloat
    public var frame: CGRect
    
    public static var `default`: Self {
        Self(id: UUID(), imageScale: 1, frame: .zero)
    }
}

public class Artboard {
//    let figmaURL: String
    public var frames: [Frame] = []
}

/// Domain object that is used for drawing
public struct Frame {
    public let name: String
    public let image: Image // TODO: Replace with url: file or remote
    public let frame: CGRect
    
    /// In absolute coordinates
    public let controls: [any AccessibilityView]
    
    public init(
        name: String,
        image: Image,
        frame: CGRect,
        controls: [any AccessibilityView]
    ) {
        self.name = name
        self.image = image
        self.frame = frame
        self.controls = controls
    }
}
