import CoreGraphics

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
    public var label: String
    
    public let image: Image // TODO: Replace with url: file or remote
    public var frame: CGRect
    
    /// In absolute coordinates
    public var elements: [any AccessibilityView]
    
    public init(
        label: String,
        image: Image,
        frame: CGRect,
        elements: [any AccessibilityView]
    ) {
        self.label = label
        self.image = image
        self.frame = frame
        self.elements = elements
    }

    // MARK: AccessibilityView
    public static func == (lhs: Frame, rhs: Frame) -> Bool {
        lhs.label == rhs.label // TODO: Better comparison
    }
    
    public var type: AccessibilityViewTypeDto = .frame
}
