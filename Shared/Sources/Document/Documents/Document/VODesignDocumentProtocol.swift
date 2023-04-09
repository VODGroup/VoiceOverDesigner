import Foundation
import Combine

public protocol VODesignDocumentProtocol: AnyObject {
    
    // MARK: - Data
    var controls: [any AccessibilityView] { get set }
    var image: Image? { get set }
    
    var frames: [Frame] { get set }
    var imageSize: CGSize { get }
    var frameInfo: FrameInfo { get set }
    
    // MARK: - Services
    /// An undo manager that records operations on document
    /// - Renamed as `NSDocument` and `UIDocument` have different `UndoManager` signature
    var undo: UndoManager? { get }
    
    var documentWrapper: FileWrapper { get set }
    
    var previewSource: PreviewSourceProtocol? { get set }
}

extension VODesignDocumentProtocol {
    public func updateImage(_ newImage: Image) {
        image = newImage
        
//        invalidateWrapperIfPossible(fileInFrame: FileName.screen)
//        invalidateWrapperIfPossible(fileInFrame: FileName.info)
        invalidateWrapperIfPossible(fileInRoot: FolderName.quickLook)
        
#if os(macOS)
        frameInfo.imageScale = newImage.recommendedLayerContentsScale(1)
#elseif os(iOS)
        frameInfo.imageScale = 1 // iOS can't extract scale information
#endif
    }
}

import CoreGraphics
public protocol PreviewSourceProtocol: AnyObject {
    func previewImage() -> Image?
}
