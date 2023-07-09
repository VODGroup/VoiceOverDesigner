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
            let filePath = documentPath()!
                .appendingPathComponent(FolderName.images)
                .appendingPathComponent(name)
            return Image(path: filePath)
            
        case .url(let url):
            // TODO: Load from the internet and cache inside a .vodesign document
            fatalError()
        case let .tmp(_, data):
            if let data {
                return Image(data: data)
            } else {
                return nil
            }
        }
    }
}
