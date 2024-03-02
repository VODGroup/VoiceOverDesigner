import Foundation
import Combine

/// Universal abstraction over UIDocument and NSDocument
public protocol VODesignDocumentProtocol: AppleDocument {
    
    // MARK: - Data
    var artboard: Artboard { get set }
    
    // MARK: - Services
    /// An undo manager that records operations on document
    /// - Renamed as `NSDocument` and `UIDocument` have different `UndoManager` signature
    var undo: UndoManager? { get }
    
    /// In-memory representation of document's structure in file system
    /// 
    /// Contains:
    /// - `Images/` folder
    /// - `document.json`
    /// - `QuickView/Preview.heic`
    var documentWrapper: FileWrapper { get set }
    
    var previewSource: PreviewSourceProtocol? { get set }
}

extension VODesignDocumentProtocol {
    public func addFrame(
        with image: Image,
        name: String?,
        origin: CGPoint
    ) {
        let imageLocation = addImageWrapper(image: image, name: name)
        let frame = Frame(imageLocation: imageLocation,
                          name: name,
                          frame: CGRect(origin: origin,
                                        size: image.size))
        artboard.append(frame)
        
        documentWrapper.invalidateIfPossible(file: FolderName.quickLook)
    }
    
    public func invalidateQuickViewPreview() {
        documentWrapper.invalidateIfPossible(file: FolderName.quickLook)
    }
    
    public func update(image: Image, for frame: Frame) {
        var featureName: String = UUID().uuidString
        
        switch frame.imageLocation {
        case .fileWrapper(let path):
            let name = URL(filePath: path).lastPathComponent
            imagesFolderWrapper.invalidateIfPossible(file: name)
            
            featureName = name // Will use to keep naming
        case .remote(_):
            fatalError("Don't know is some code is needed here")
        }
        
        let imageWrapper = FileWrapper(regularFileWithContents: image.png()!)
        imageWrapper.preferredFilename = featureName
        imagesFolderWrapper.addFileWrapper(imageWrapper)
        
        // TODO: Add to cache folder with given name
        frame.imageLocation = .fileWrapper(name: featureName)
        let image = artboard.imageLoader.image(for: frame)
        
        frame.frame = CGRect(origin: frame.frame.origin,
                             size: image?.size ?? frame.frame.size)
    }
}

extension Artboard {
    
    public func suggestOrigin() -> CGPoint {
        guard let lastFrame = frames.last?.frame
        else { return .zero }
        
        let origin = CGPoint(x: lastFrame.maxX + lastFrame.width * 0.2,
                             y: lastFrame.minY)
        return origin
    }
    func suggestFrame(for size: CGSize) -> CGRect {
        return CGRect(origin: suggestOrigin(), size: size)
    }
}

import CoreGraphics
public protocol PreviewSourceProtocol: AnyObject {
    func previewImage() -> Image?
}

extension Frame {
    public convenience init(
        imageLocation: ImageLocation,
        name: String?,
        frame: CGRect
    ) { 
        let name = name ?? UUID().uuidString
        
        self.init(label: name,
                  imageLocation: imageLocation,
                  frame: frame,
                  elements: [])
    }
}
