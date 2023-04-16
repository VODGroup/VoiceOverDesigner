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
    public var controlsWithoutFrames: [any AccessibilityView] = []
}

/// Domain object that is used for drawing
public class Frame: AccessibilityView {
    @DecodableDefault.RandomUUID
    public var id: UUID
    
    public var label: String
    
    public let image: Image // TODO: Replace with url: file or remote
    public var frame: CGRect
    
    /// In absolute coordinates
    public var controls: [any AccessibilityView]
    
    public init(
        label: String,
        image: Image,
        frame: CGRect,
        controls: [any AccessibilityView]
    ) {
        self.label = label
        self.image = image
        self.frame = frame
        self.controls = controls
    }

    // MARK: AccessibilityView
    public static func == (lhs: Frame, rhs: Frame) -> Bool {
        lhs.label == rhs.label // TODO: Better comparison
    }
    
    public var type: AccessibilityViewTypeDto = .frame
}
