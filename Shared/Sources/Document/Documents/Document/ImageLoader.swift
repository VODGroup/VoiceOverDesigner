import Foundation
import Artboard

/// Loads remote or local image
public class ImageLoader: ImageLoading {
    public typealias DocumentPath = () -> URL?
    let documentPath: DocumentPath
    public init(documentPath: @escaping DocumentPath) {
        self.documentPath = documentPath
    }
    
    /// Path to image cache
    private var imageCache: [URL: Image] = [:]
    // TODO: Remove from cache when delete frame
    
    public func image(for frame: Frame) -> Image? {
        switch frame.imageLocation {
        case .relativeFile(let path):
            let filePath = fullPath(relativeTo: path)
            
            print("Load image relative path: \(filePath)")
            
            if let image = imageCache[filePath] {
                return image
            }
            
            let image = Image(path: filePath)
            imageCache[filePath] = image
            return image
            
        case .remote(let url):
            print("Load remote image from \(url.path)")
                // TODO: Load from the internet and cache inside a .vodesign document
                fatalError()
        case .cache(let image, _):
            return image
        }
    }
    
    public func fullPath(relativeTo relativePath: String) -> URL {
        documentPath()!
            .appendingPathComponent(relativePath)
    }
}
