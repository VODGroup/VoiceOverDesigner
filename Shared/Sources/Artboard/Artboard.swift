import CoreGraphics

import Foundation

#if os(iOS)
import UIKit
public typealias Image = UIImage
public extension Image {
    convenience init?(path: URL) {
        self.init(contentsOfFile: path.path)
    }
}

#elseif os(macOS)
import AppKit
public typealias Image = NSImage
public extension Image {
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
    
    public var isEmpty: Bool {
        frames.isEmpty && controlsWithoutFrames.isEmpty
    }
}

/// Domain object that is used for drawing
public class Frame: ArtboardContainer, ObservableObject {
    public var type: ArtboardType = .frame
    
    @DecodableDefault.RandomUUID
    public var id: UUID
    public var label: String {
        willSet { objectWillChange.send() }
    }
    public var imageLocation: ImageLocation {
        willSet { objectWillChange.send() }
    }

    public var frame: CGRect
    
    /// In absolute coordinates
    public var elements: [any ArtboardElement]
    public var parent: (any ArtboardContainer)? = nil
    
    public convenience init(
        label: String,
        imageName: String,
        frame: CGRect,
        elements: [any ArtboardElement]
    ) {
        self.init(label: label,
                  imageLocation: .file(name: imageName),
                  frame: frame,
                  elements: elements)
    }
    
    public init(
        label: String,
        imageLocation: ImageLocation,
        frame: CGRect,
        elements: [any ArtboardElement]
    ) {
        self.label = label
        self.imageLocation = imageLocation
        self.frame = frame
        self.elements = elements
        
        for element in elements {
            element.parent = self
        }
    }

    // MARK: ArtboardElement
    public static func == (lhs: Frame, rhs: Frame) -> Bool {
        lhs.label == rhs.label &&
        lhs.imageLocation == rhs.imageLocation
    }
}

public enum ImageLocation: Equatable {
    case cache(image: NSImage)
    case file(name: String)
    case url(url: URL)
    
    public static func from(dto: ImageLocationDto) -> Self {
        switch dto {
        case .file(let name): return .file(name: name)
        case .url(let url): return .url(url: url)
        }
    }
}

public enum ImageLocationDto: Codable {
    case file(name: String)
    case url(url: URL)
    /// Temporary data stored during design process, shouldn't be encoded
    case tmp(name: String, data: Data?)
}

public protocol ImageLoading {
    func image(for frame: Frame) -> Image?
}

public class DummyImageLoader: ImageLoading {
    public init() {}
    
    public func image(for frame: Frame) -> Image? {
        return nil
    }
}
