import Foundation
import Artboard

/// Loads remote or local image
public class ImageLoader: ImageLoading {
    public typealias DocumentPath = () -> URL?
    let documentPath: DocumentPath
    public init(documentPath: @escaping DocumentPath) {
        self.documentPath = documentPath
    }
    public func image(for frame: Frame) -> Image? {
        switch frame.imageLocation {
        case .relativeFile(let path):
            let filePath = fullPath(relativeTo: path)
            
            print("Load image relative path: \(filePath)")
            
            return Image(path: filePath)
            
        case .remote(let url):
            print("Load remote image from \(url.path)")
                // TODO: Load from the internet and cache inside a .vodesign document
                fatalError()
        case .cache(let image, let name):
            return image
        }
    }
    
    public func fullPath(relativeTo relativePath: String) -> URL {
        documentPath()!
            .appendingPathComponent(relativePath)
    }
}
