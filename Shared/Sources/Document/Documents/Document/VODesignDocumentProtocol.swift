import Foundation
import Combine

public protocol VODesignDocumentProtocol: AnyObject {
    
    // MARK: - Data
    var controls: [any AccessibilityView] { get set }
    var image: Image? { get set }
    var imageSize: CGSize { get }
    var frameInfo: FrameInfo { get set }
    
    // MARK: - Services
    /// An undo manager that records operations on document
    /// - Renamed as `NSDocument` and `UIDocument` have different `UndoManager` signature
    var undo: UndoManager? { get }
}

extension VODesignDocumentProtocol {
    public func updateImage(_ newImage: Image) {
        image = newImage
        
#if os(macOS)
        frameInfo.imageScale = newImage.recommendedLayerContentsScale(1)
#elseif os(iOS)
        frameInfo.imageScale = 1 // iOS can't exract scale information
#endif
    }
    
    func read(
        from packageWrapper: FileWrapper
    ) throws {
        
        guard packageWrapper.isDirectory else {
            print("Nothing to read, probably the document was just created")
            return
        }
        
        let frameFolder = (packageWrapper.fileWrappers?[defaultFrameName]?.fileWrappers ?? packageWrapper.fileWrappers)!

        if
            let controlsWrapper = frameFolder[FileName.controls],
            let controlsData = controlsWrapper.regularFileContents
        {
            let codingService = AccessibilityViewCodingService()
            controls = try codingService.controls(from: controlsData)
        }

        if let imageWrapper = frameFolder[FileName.screen],
           let imageData = imageWrapper.regularFileContents {
            image = Image(data: imageData)
        }

        if let frameInfoWrapper = frameFolder[FileName.info],
           let infoData = frameInfoWrapper.regularFileContents,
            let info = try? JSONDecoder().decode(FrameInfo.self,
                                                 from: infoData) {
            frameInfo = info
        }
    }
}
