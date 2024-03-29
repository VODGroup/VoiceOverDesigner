import Foundation
import QuickLookThumbnailing

public extension URL {
    var fileName: String {
        deletingPathExtension().lastPathComponent
    }
}

public class ThumbnailDocument {
    
    public init(documentURL: URL) {
        self.documentURL = documentURL
    }
    
    private var documentURL: URL
    
    private var thumbnailCache: Image?
    public func thumbnail(
        size: CGSize,
        scale: CGFloat
    ) async -> Image? {
        if let thumbnailCache {
            // TODO: Invalidate cache if other size is requested
            return thumbnailCache
        }
        
        var imagePath = ImageSaveService(
            url: documentURL,
            fileName: FolderName.quickLookPath).file
        
        if !FileManager.default.fileExists(atPath: imagePath.path) {
            imagePath = ImageSaveService(
                url: documentURL,
                fileName: "QuickView/Preview.png").file
        }
        
        let request = QLThumbnailGenerator.Request(
            fileAt: imagePath,
            size: size,
            scale: scale,
            representationTypes: .thumbnail)
        
        let previewGenerator = QLThumbnailGenerator()
        
        do {
            let thumbnail = try await previewGenerator.generateBestRepresentation(for: request)
            
#if canImport(AppKit)
            thumbnailCache = thumbnail.nsImage
            return thumbnail.nsImage
#else
            thumbnailCache = thumbnail.uiImage
            return thumbnail.uiImage
#endif
        } catch let error {
            print(error)
            return nil
        }
    }
}
