#if os(iOS) || os(visionOS)
import UIKit
public typealias AppleDocument = UIDocument
import Combine
import Artboard

public class VODesignDocument: AppleDocument, VODesignDocumentProtocol {
    
    // MARK: - Data
    public var elements: [any ArtboardElement] = []
    public var image: Image?
    public var frameInfo: FrameInfo = .default
    public lazy var artboard: Artboard = {
        let artboard = Artboard()
        artboard.imageLoader = ImageLoader(documentPath: { [weak self] in self?.fileURL
        })
        return artboard
    }()
    
    var version: DocumentVersion!
    
    public var imageSize: CGSize {
        return image?
            .size
            .inverted(scale: frameInfo.imageScale)
        ?? .zero
    }
    
    public var documentWrapper = FileWrapper(directoryWithFileWrappers: [:])
    
    public var previewSource: PreviewSourceProtocol?
    
    // MARK: -
    
    public var undo: UndoManager? {
        undoManager
    }
    
    public convenience init(fileName: String,
                            rootPath: URL = iCloudContainer) {
        let dir = rootPath.appendingPathComponent(fileName)
        do {
            let _ = try FileManager.default
                .contentsOfDirectory(
                    atPath: dir.path)
        } catch let error {
            print("Can't read \(rootPath), error: \(error)")
        }
        
        self.init(fileURL: dir)
    }
    
    // MARK: - Override
    public override func contents(forType typeName: String) throws -> Any {
        Swift.print("Will save")
        storeImagesAsFileWrappers()
        return try fileWrapper()
    }
    
    // TODO: Remove duplication with AppKit
    public override func load(fromContents contents: Any, ofType typeName: String?) throws {
        undoManager?.disableUndoRegistration()
        defer { undoManager?.enableUndoRegistration() }
        
        let packageWrapper = contents as! FileWrapper
        
        undoManager?.disableUndoRegistration()
        defer { undoManager?.enableUndoRegistration() }
        
        do {
            let (version, artboard) = try read(from: packageWrapper)
            
            self.artboard = artboard
            self.version = version
            artboard.imageLoader = ImageLoader(documentPath: { [weak self] in
                self?.fileURL
            })
            
            prepareFormatForArtboard(for: version)
            
        } catch let error {
            Swift.print(error)
            throw error
        }
    }
}

extension UIDocument {
    public func printState() {
        if documentState == .normal {
            print("documentState: [normal]" )
        }
        var readableStrings = [String]()
        if documentState.contains(.inConflict) {
            readableStrings.append("inConflict")
        }
        if documentState.contains(.editingDisabled) {
            readableStrings.append("editingDisabled")
        }
        if documentState.contains(.progressAvailable) {
            readableStrings.append("progressAvailable")
        }
        if documentState.contains(.savingError) {
            readableStrings.append("savingError")
        }
        if documentState.contains(.closed) {
            readableStrings.append("closed")
        }
        print("documentState: \(readableStrings)")
    }
}
#endif

import CoreGraphics
extension CGSize {
    public func inverted(scale: CGFloat) -> Self {
        let transform = CGAffineTransform(scaleX: 1/scale,
                                          y: 1/scale)
        return applying(transform)
    }
}
