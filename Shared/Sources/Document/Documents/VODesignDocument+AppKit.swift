#if os(macOS)
// MARK: - AppKit
import AppKit
public typealias Document = NSDocument

import os

public let vodesign = "vodesign"
public let uti = "com.akaDuality.vodesign"

public class VODesignDocument: Document, VODesignDocumentProtocol {
    
    // MARK: - Data
    public var image: Image?
    public var controls: [any AccessibilityView] = []
    
    // MARK:
    
    public var undo: UndoManager? {
        undoManager
    }
    
    // MARK: - Constructors
    public convenience init(fileName: String,
                            rootPath: URL = iCloudContainer) {
        let file = rootPath.appendingPathComponent(fileName).appendingPathExtension(vodesign)
        
        self.init(file: file)
        
        fileType = vodesign
    }
    
    private let codingService = AccessibilityViewCodingService()
    private lazy var imageService = ImageSaveService()
    
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
        self.image = image
    }
    
    // MARK: - Override
    
    public override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        Swift.print("Will save")
        let package = FileWrapper(directoryWithFileWrappers: [:])
        
        package.addFileWrapper(try controlsWrapper())
        
        // TODO: Save only if image has been changed. It should simplify iCloud sync
        if let imageWrapper = imageWrapper() {
            package.addFileWrapper(imageWrapper)
        }
        
        // TODO: Save only if image has been changed. It should simplify iCloud sync
        if let previewWrapper = previewWrapper() {
            package.addFileWrapper(previewWrapper)
        }
        
        return package
    }
    
    public override func read(from url: URL, ofType typeName: String) throws {
        Swift.print("Read from \(url)")
        defer { undoManager?.enableUndoRegistration() }
        undoManager?.disableUndoRegistration()
        
        let documentSaveService = DocumentSaveService(fileURL: url.appendingPathComponent("controls.json"))
        controls = try documentSaveService.loadControls()
        
        image = try? imageService.load(from: url)
    }
    
    // MARK: Static
    public override class var autosavesInPlace: Bool {
        return true
    }
    
    public static func image(from url: URL) -> Image? {
        try? ImageSaveService().load(from: url)
    }
    
    public override class var readableTypes: [String] {
        [uti]
    }
    
    public override class var writableTypes: [String] {
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
}

// MARK: - File wrappers
extension VODesignDocument {
    private func controlsWrapper() throws -> FileWrapper {
        let wrapper = FileWrapper(regularFileWithContents: try codingService.data(from: controls))
        wrapper.preferredFilename = "controls.json"
        return wrapper
    }
    
    private func imageWrapper() -> FileWrapper? {
        guard let image = image,
              let imageData = imageService.UIImagePNGRepresentation(image),
              shouldSaveImage(imageData: imageData)
        else { return nil }
        
        let imageWrapper = FileWrapper(regularFileWithContents: imageData)
        imageWrapper.preferredFilename = "screen.png"
        
        return imageWrapper
    }
    
    private func previewWrapper() -> FileWrapper? {
        guard let image = image,
              let imageData = imageService.UIImagePNGRepresentation(image),
              shouldSaveImage(imageData: imageData)
        else { return nil }
        
        let imageWrapper = FileWrapper(regularFileWithContents: imageData)
        imageWrapper.preferredFilename = QuickLookFileName
        
        let quicklookFolder = FileWrapper(directoryWithFileWrappers: [QuickLookFolderName: imageWrapper])
        quicklookFolder.preferredFilename = QuickLookFolderName
        return quicklookFolder
    }
    
    private func shouldSaveImage(imageData: Data) -> Bool {
        let storedData = fileURL.flatMap{ try? imageService.load(from: $0) }.flatMap(imageService.UIImagePNGRepresentation(_:))
        return imageData != storedData
    }
}
#endif
