import CoreGraphics

// If feature we can wrap document's data in frame and make array of frames
//public struct Frame {

//    public var controls: [any AccessibilityView] = []
//    public var image: Image?
//    public var frameInfo: FrameInfo
//}

import Foundation
public struct FrameInfo: Codable {
    public var id: UUID
    public var imageScale: CGFloat
    
    public static var `default`: Self {
        Self(id: UUID(), imageScale: 1)
    }
}
