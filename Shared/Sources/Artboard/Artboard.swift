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

/// Data layer with hierarchical structure of element
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
        self.init(
            id: UUID(),
            label: label,
            imageLocation: .relativeFile(path: imageName),
            frame: frame,
            elements: elements)
    }
    
    public init(
        id: UUID = UUID(),
        label: String,
        imageLocation: ImageLocation,
        frame: CGRect,
        elements: [any ArtboardElement]
    ) {
        self.id = id
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
    case cache(image: Image, name: String)
    case relativeFile(path: String)
    case remote(url: URL)
    
    public static func from(dto: ImageLocationDto) -> Self {
        switch dto {
        case .relativeFile(let name): return .relativeFile(path: name)
        case .remote(let url): return .remote(url: url)
        case .tmp(name: let name, data: let data):
            // TODO: Optionals
            return .cache(image: Image(data: data!)!, name: name)
        }
    }
}

public enum ImageLocationDto: Codable {
    case relativeFile(path: String)
    case remote(url: URL)
    /// Temporary data stored during design process, shouldn't be encoded
    case tmp(name: String, data: Data?)
    
    public static func from(_ model: ImageLocation) -> Self {
        switch model {
        case .relativeFile(let path): return .relativeFile(path: path)
        case .remote(let url): return .remote(url: url)
        case .cache(image: let image):
            // TODO: Add code
            // return .tmp(name: <#T##String#>, data: <#T##Data?#>)
            fatalError()
        }
    }
}

public protocol ImageLoading {
    func image(for frame: Frame) -> Image?
    func fullPath(relativeTo relativePath: String) -> URL
}

public class DummyImageLoader: ImageLoading {
    public init() {}
    
    public func image(for frame: Frame) -> Image? {
        return nil
    }
    
    public func fullPath(relativeTo relativePath: String) -> URL {
        return URL(string: "")!
    }
}
