import Foundation

#if os(iOS) || os(visionOS)
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

public enum ImageLocation: Equatable {
    case fileWrapper(name: String)
    case remote(url: URL)
    
    public static func from(dto: ImageLocationDto) -> Self {
        switch dto {
        case .fileWrapper(let name): return .fileWrapper(name: name)
        case .remote(let url): return .remote(url: url)
        }
    }
}

public enum ImageLocationDto: Codable {
    case fileWrapper(name: String)
    case remote(url: URL)
    
    public static func from(_ model: ImageLocation) -> Self {
        switch model {
        case .fileWrapper(let path): return .fileWrapper(name: path)
        case .remote(let url): return .remote(url: url)
        }
    }
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
