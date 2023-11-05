import Foundation
import Artboard

public class ImageLoader: ImageLoading {
    public typealias DocumentPath = () -> URL?
    let documentPath: DocumentPath
    public init(documentPath: @escaping DocumentPath) {
        self.documentPath = documentPath
    }
    public func image(for frame: Frame) -> Image? {
        switch frame.imageLocation {
        case .file(let name):
            // TODO: Remove
            let filePath = documentPath()!
                .appendingPathComponent(FolderName.images)
                .appendingPathComponent(name)
            return Image(path: filePath)
            
        case .url(let url):
            if url.isFileURL {
                return Image(path: url)
            } else {
                // TODO: Load from the internet and cache inside a .vodesign document
                fatalError()
            }
        case .cache(let image):
            return image
        }
    }
    
    public func url(for imageName: String) -> URL {
        documentPath()!
            .appendingPathComponent(FolderName.images)
            .appendingPathComponent(imageName)
    }
}
