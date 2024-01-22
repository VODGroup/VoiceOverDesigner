import Foundation
import Artboard

extension VODesignDocument: ImageLoading {
    public func image(for frame: Frame) -> Image? {
        switch frame.imageLocation {
        case .fileWrapper(let path):
            guard let imageName = path.components(separatedBy: "/").last,
                  let imageData = imagesFolderWrapper.fileWrappers?[imageName]?
                .regularFileContents
            else {
                Swift.print("Can't find image \(path)")
                return nil
            }
            
           return Image(data: imageData)
            
        case .remote(let url):
            Swift.print("Load remote image from \(url.path)")
            // TODO: Load from the internet and cache inside a .vodesign document
            fatalError()
        }
    }
    
    public func fullPath(relativeTo relativePath: String) -> URL? {
        fileURL?.appendingPathComponent(relativePath)
    }
}
