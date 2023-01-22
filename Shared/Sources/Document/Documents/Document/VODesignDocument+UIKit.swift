#if os(iOS)
import UIKit
public typealias Document = UIDocument
import Combine

public class VODesignDocument: Document, VODesignDocumentProtocol {
    
    // MARK: - Data
    public var controls: [any AccessibilityView] = []
    public var image: Image?
    public var frameInfo: FrameInfo = .default
    
    public var imageSize: CGSize {
        return image?
            .size
            .inverted(scale: frameInfo.imageScale)
        ?? .zero
    }
    
    // MARK: -
    
    public var undo: UndoManager? {
        undoManager
    }
    
    public convenience init(fileName: String,
                            rootPath: URL = iCloudContainer) {
        let dir = rootPath.appendingPathComponent(fileName)
        do {
            let content = try FileManager.default
                .contentsOfDirectory(
                    atPath: dir.path)
        } catch let error {
            print("Can't read \(rootPath), error: \(error)")
        }
        
        self.init(fileURL: dir)
    }
    
    // MARK: - Override
    // TODO: AppKit version uses filewrappers. Extract and reuse them?
    public override func save(
        to url: URL,
        for saveOperation: Document.SaveOperation
    ) async -> Bool {
        
        let frameReader = FrameReader(documentURL: url, frameName: defaultFrameName)
        
        do {
            try frameReader.saveService.save(controls: controls)
            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    public override func read(from url: URL) throws {
        
        let frameReader = FrameReader(documentURL: url)
        
        controls = try frameReader.saveService.loadControls()
        image = try? frameReader.imageSaveService.load()
        frameInfo = frameReader.frameInfoPersistance
                .readFrame() ?? .default
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
