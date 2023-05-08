import CoreGraphics

import Foundation

#if os(iOS)
import UIKit
public typealias Image = UIImage

#elseif os(macOS)
import AppKit
public typealias Image = NSImage
#endif

/// Data layer with hierarchical structure if element
public class Artboard {
//    let figmaURL: String
    public var frames: [Frame]
    public var controlsWithoutFrames: [any ArtboardElement]
    
    public init(
        frames: [Frame] = [],
        controlsWithoutFrames: [any ArtboardElement] = []) {
        self.frames = frames
        self.controlsWithoutFrames = controlsWithoutFrames
    }
}

/// Domain object that is used for drawing
public class Frame: ArtboardContainer {
    public var type: ArtboardType = .frame
    
    public var label: String
    public let imageName: String
    public let image: Image? // TODO: Replace with url: file or remote
    public var frame: CGRect
    
    /// In absolute coordinates
    public var elements: [any ArtboardElement]
    public var parent: (any ArtboardContainer)? = nil
    
    public init(
        label: String,
        imageName: String,
        image: Image?,
        frame: CGRect,
        elements: [any ArtboardElement]
    ) {
        self.label = label
        self.imageName = imageName
        self.image = image
        self.frame = frame
        self.elements = elements
        
        for element in elements {
            element.parent = self
        }
    }

    // MARK: ArtboardElement
    public static func == (lhs: Frame, rhs: Frame) -> Bool {
        lhs.label == rhs.label // TODO: Better comparison
    }
}

