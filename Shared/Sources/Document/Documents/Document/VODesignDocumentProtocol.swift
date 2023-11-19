import Foundation
import Combine

/// Universal abstraction over UIDocument and NSDocument
public protocol VODesignDocumentProtocol: AnyObject {
    
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
    @available(*, deprecated, message: "Use `artboard`")
    public var controls: [any ArtboardElement] {
        get {
            artboard.controlsWithoutFrames
        }
        
        set {
            artboard.controlsWithoutFrames = newValue
        }
    }
}

extension VODesignDocumentProtocol {
    public func addFrame(
        with newImage: Image,
        origin: CGPoint
    ) {
        let frame = Frame(image: newImage,
                          frame: CGRect(origin: origin,
                                        size: newImage.size))
        artboard.frames.append(frame)
        
        documentWrapper.invalidateIfPossible(file: FolderName.quickLook)
    }
    
    public func invalidateQuickViewPreview() {
        documentWrapper.invalidateIfPossible(file: FolderName.quickLook)
    }
    
    public func update(image: Image, for frame: Frame) {
        var featureName: String = UUID().uuidString
        
        switch frame.imageLocation {
        case .relativeFile(let path):
            let name = URL(filePath: path).lastPathComponent
            imagesFolderWrapper.invalidateIfPossible(file: name)
            
            featureName = name // Will use to keep naming
        case .remote(let url):
            fatalError("Don't know is some code is needed here")
        case .cache(_):
            // TODO: convert to file
            fatalError("Remove old file from cache")
//            imagesFolderWrapper.invalidateIfPossible(file: name)
        }
        
        // TODO: Add to cache folder with given name
        frame.imageLocation = .cache(image: image, name: featureName)
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
    public convenience init(image: Image, frame: CGRect) {
        let name = UUID().uuidString // TODO: Create fancy name

//        let frame = CGRect(origin: .zero, size: image.size)
        
        self.init(label: name,
                  imageLocation: .cache(image: image,
                                        name: UUID().uuidString), // TODO: Make fancy name. Call to ChatGPT!!
                  frame: frame,
                  elements: [])
    }
}
