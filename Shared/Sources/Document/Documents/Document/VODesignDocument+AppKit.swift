#if os(macOS)
// MARK: - AppKit
import AppKit
public typealias AppleDocument = NSDocument

import os

import QuickLookThumbnailing

public class VODesignDocument: AppleDocument, VODesignDocumentProtocol {

    // MARK: - Data
    @available(*, deprecated, message: "Use `artboard`")
    public var elements: [any ArtboardElement] = []
    
    public var artboard: Artboard = Artboard()
    
    public var documentWrapper = FileWrapper(directoryWithFileWrappers: [:])
    
    public var previewSource: PreviewSourceProtocol?
    
    // MARK: - Constructors
    public convenience init(fileName: String,
                            rootPath: URL = iCloudContainer) {
        let file = rootPath.appendingPathComponent(fileName).appendingPathExtension(vodesign)
        
        self.init(file: file)
    }
    
    public convenience init(file: URL) {
        do {
            try self.init(contentsOf: file,
                          ofType: uti)
        } catch let error {
            Swift.print(error)
            // TODO: Is it ok?
            try! self.init(type: uti)
        }
    }
    
    public convenience init(image: NSImage) {
        try! self.init(type: uti)
        
        displayName = image.name() ?? Date().description
        
        addFrame(with: image)
    }
    
    // MARK: - Override
    
    public override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        Swift.print("Will save")
        return try fileWrapper()
    }
    
    override public func read(from packageWrapper: FileWrapper, ofType typeName: String) throws {
        
        undoManager?.disableUndoRegistration()
        defer { undoManager?.enableUndoRegistration() }
        
        do {
            try read(from: packageWrapper)
        } catch let error {
            Swift.print(error)
            throw error
        }
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
