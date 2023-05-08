import Foundation
import Combine

public protocol VODesignDocumentProtocol: AnyObject {
    
    // MARK: - Data
    var artboard: Artboard { get set }
    
    // MARK: - Services
    /// An undo manager that records operations on document
    /// - Renamed as `NSDocument` and `UIDocument` have different `UndoManager` signature
    var undo: UndoManager? { get }
    
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
    public func addFrame(with newImage: Image) {
        let frame = Frame(image: newImage)
        artboard.frames.append(frame)
        
        invalidateWrapperIfPossible(fileInRoot: FolderName.quickLook)
    }
}

import CoreGraphics
public protocol PreviewSourceProtocol: AnyObject {
    func previewImage() -> Image?
}

extension Frame {
    public convenience init(image: Image) {
        let name = UUID().uuidString // TODO: Create fancy name

        let frame = CGRect(origin: .zero, size: image.size)
        
        self.init(label: name,
                  imageName: name,
                  image: image,
                  frame: frame,
                  elements: [])
    }
}
