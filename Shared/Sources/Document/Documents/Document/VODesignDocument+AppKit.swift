#if os(macOS)
// MARK: - AppKit
import AppKit
public typealias AppleDocument = NSDocument

import os

import QuickLookThumbnailing

/// NSDocument subclass, represents `.vodesign` document's format
public class VODesignDocument: AppleDocument, VODesignDocumentProtocol {

    // MARK: - Data
    @available(*, deprecated, message: "Use `artboard`")
    public var elements: [any ArtboardElement] = []
    
    public lazy var artboard: Artboard = {
        let artboard = Artboard()
        artboard.imageLoader = ImageLoader(documentPath: { [weak self] in self?.fileURL
        })
        return artboard
    }()
    
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
        
        addFrame(with: image, origin: .zero)
    }
    
    var version: DocumentVersion!
    
    // MARK: - Override
    
    /// Writing operation. 
    ///
    /// Update's file structure during saving.
    override public func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        Swift.print("Will save")
        storeImagesAsFileWrappers()
        return try fileWrapper()
    }
    
    /// Reads artboard and prepare artboard after migration in memory.
    ///
    /// > Important: Keep ``documentWrapper`` as reference to files, update it if you need invalidation
    ///
    /// > Note: Does not change document's structure
    override public func read(from packageWrapper: FileWrapper, ofType typeName: String) throws {
        
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
    
    private func prepareFormatForArtboard(for version: DocumentVersion) {
        switch version {
        case .beta:
            createEmptyDocumentWrapper()
        case .release:
            break
        case .artboard:
            break
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
    
    public override var displayName: String! {
        get {
            let parts = super.displayName.split(separator: ".")
            
            if parts.count > 1 {
                return parts.dropLast().joined(separator: ".") // "SomeDocumentName.vodesign"
            } else {
                return super.displayName // "Untitled 4"
            }
        }
        set {
            super.displayName = newValue
        }
    }
}
#endif
