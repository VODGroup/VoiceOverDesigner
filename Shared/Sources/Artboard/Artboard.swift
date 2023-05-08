import CoreGraphics

import Foundation

#if os(iOS)
import UIKit
public typealias Image = UIImage
extension Image {
    convenience init?(path: URL) {
        self.init(contentsOfFile: path.path)
    }
}

#elseif os(macOS)
import AppKit
public typealias Image = NSImage
extension Image {
    convenience init?(path: URL) {
        self.init(contentsOf: path)
    }
}
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
    
    public var imageLoader: ImageLoading!
}

/// Domain object that is used for drawing
public class Frame: ArtboardContainer {
    public var type: ArtboardType = .frame
    
    public var label: String
    public let imageName: String
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


public protocol ImageLoading {
    func image(for frame: Frame) -> Image?
}

import Foundation
public class ImageLoader: ImageLoading {
    public typealias DocumentPath = () -> URL?
    let documentPath: DocumentPath
    public init(documentPath: @escaping DocumentPath) {
        self.documentPath = documentPath
    }
    public func image(for frame: Frame) -> Image? {
        let filePath = documentPath()!
            .appendingPathComponent("Images")
            .appendingPathComponent(frame.imageName)
            .appendingPathExtension("png")
        
        return Image(path: filePath)
//            frame.image?.defaultCGImage
    }
}

public class DummyImageLoader: ImageLoading {
    public init() {}
    
    public func image(for frame: Frame) -> Image? {
        return nil
    }
}
