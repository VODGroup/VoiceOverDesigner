import Foundation
import QuickLookThumbnailing

public extension URL {
    var fileName: String {
        deletingPathExtension().lastPathComponent
    }
}

public class ThumbnailDocument {
    
    public init(frameURL: URL) {
        self.frameURL = frameURL
    }
    
    private var frameURL: URL
    
    private var thumbnailCache: Image?
    public func thumbnail(
        size: CGSize,
        scale: CGFloat
    ) async -> Image? {
        if let thumbnailCache {
            // TODO: Invalidate cache if other size is requested
            return thumbnailCache
        }
        
        let imagePath = ImageSaveService(
            url: frameURL,
            fileName: FileName.screen).file
        
        let request = QLThumbnailGenerator.Request(
            fileAt: imagePath,
            size: size,
            scale: scale,
            representationTypes: .thumbnail)
        
        let previewGenerator = QLThumbnailGenerator()
        let thumbnail = try? await previewGenerator.generateBestRepresentation(for: request)
        
        #if canImport(AppKit)
        thumbnailCache = thumbnail?.nsImage
        return thumbnail?.nsImage
        #else
        thumbnailCache = thumbnail?.uiImage
        return thumbnail?.uiImage
        #endif
    }
}