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

/// Domain object that is used for drawing
public struct Frame {
    public let image: Image
    public let frame: CGRect
    
    public init(image: Image, frame: CGRect) {
        self.image = image
        self.frame = frame
    }
}
