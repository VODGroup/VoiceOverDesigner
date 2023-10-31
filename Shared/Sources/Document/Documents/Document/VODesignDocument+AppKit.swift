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
    
    // MARK: - Override
    
    public override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        Swift.print("Will save")
        return try fileWrapper()
    }
    
    override public func read(from packageWrapper: FileWrapper, ofType typeName: String) throws {
        
        undoManager?.disableUndoRegistration()
        defer { undoManager?.enableUndoRegistration() }
        
        do {
            let (version, artboard) = try read(from: packageWrapper)
            
            self.artboard = artboard
            artboard.imageLoader = ImageLoader(documentPath: { [weak self] in self?.fileURL
            })
            
            try! performDocumentMigration(from: version)
            
        } catch let error {
            Swift.print(error)
            throw error
        }
    }
    
    private func performDocumentMigration(from version: DocumentVersion) throws {
        let fileManager = FileManager.default
        switch version {
        case .beta:
            // TODO: Move image inside "Image" folder
            if let fileURL {
                let fromPath = fileURL.appendingPathComponent("screen.png")
                var toPath = fileURL.appendingPathComponent(FolderName.images)
                try fileManager.createDirectory(at: toPath, withIntermediateDirectories: true)
                
                toPath = toPath.appendingPathComponent("Frame.png")
                try fileManager.moveItem(
                    at: fromPath,
                    to: toPath)
            }
           
            recreateDocumentWrapper()
        case .release:
            if let fileURL {
                let fromPath = fileURL.appendingPathComponent("Frame/screen.png")
                var toPath = fileURL.appendingPathComponent(FolderName.images)
                try fileManager.createDirectory(at: toPath, withIntermediateDirectories: true)
                
                toPath = toPath.appendingPathComponent("Frame.png")
                try fileManager.moveItem(
                    at: fromPath,
                    to: toPath)
            }
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
