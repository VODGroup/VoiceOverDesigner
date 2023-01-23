#if os(macOS)
// MARK: - AppKit
import AppKit
public typealias Document = NSDocument

import os

import QuickLookThumbnailing

public class VODesignDocument: Document, VODesignDocumentProtocol {

    // MARK: - Data
    public var controls: [any AccessibilityView] = []
    public var image: Image?
    public var imageSize: CGSize {
        guard let image else { return .zero }
        return image.size
    }
    public var frameInfo: FrameInfo = .default
    
    public var documentWrapper = FileWrapper(directoryWithFileWrappers: [:])
    
    // MARK: - Constructors
    public convenience init(fileName: String,
                            rootPath: URL = iCloudContainer) {
        let file = rootPath.appendingPathComponent(fileName).appendingPathExtension(vodesign)
        
        self.init(file: file)
        
        fileType = vodesign
    }
    
    public convenience init(file: URL) {
        do {
            try self.init(contentsOf: file,
                          ofType: vodesign)
        } catch let error {
            Swift.print(error)
            // TODO: Is it ok?
            try! self.init(type: vodesign)
        }
    }
    
    public convenience init(image: NSImage) {
        self.init(fileName: image.name() ?? Date().description)
        
        updateImage(image)
    }
    
    // MARK: - Override
    
    public override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        Swift.print("Will save")
        return try fileWrapper()
    }
    
    override public func read(from packageWrapper: FileWrapper, ofType typeName: String) throws {
        
        undoManager?.disableUndoRegistration()
        defer { undoManager?.enableUndoRegistration() }
        
        try read(from: packageWrapper)
    }
    
    // MARK: Static
    public override class var autosavesInPlace: Bool {
        return true
    }
    
    public override class var readableTypes: [String] {
        // TODO: should be read from Info.plist
        [uti]
    }
    
    public override class var writableTypes: [String] {
        // TODO: should be read from Info.plist
        [uti]
    }
    
    public override func writableTypes(for saveOperation: NSDocument.SaveOperationType) -> [String] {
        fileType = uti
        return super.writableTypes(for: saveOperation)
    }
    
    public override func prepareSavePanel(_ savePanel: NSSavePanel) -> Bool {
        savePanel.isExtensionHidden = false
        return true
    }
    
    public static override func isNativeType(_ type: String) -> Bool {
        return true
    }
    
    // MARK:
    
    public var undo: UndoManager? {
        undoManager
    }
}
#endif
