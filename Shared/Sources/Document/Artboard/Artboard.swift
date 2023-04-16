import CoreGraphics

import Foundation

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
