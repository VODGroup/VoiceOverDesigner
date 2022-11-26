#if os(macOS)
// MARK: - AppKit
import AppKit
public typealias Document = NSDocument

import os
import Foundation
import Combine

public protocol VODesignDocumentProtocol {
    var controls: [any AccessibilityView] { get set }
    var undoManager: UndoManager? { get }
    var image: Image? { get set }
    
    var controlsPublisher: PassthroughSubject<[any AccessibilityView], Never> { get }
}

public class VODesignDocument: Document, VODesignDocumentProtocol {
    public static var vodesign = "vodesign"
    public static var uti = "com.akaDuality.vodesign"
    
    // MARK: - Data
    public var image: Image?
    
    public let controlsPublisher: PassthroughSubject<[any AccessibilityView], Never> = .init()
    
    public var controls: [any AccessibilityView] = [] {
        didSet {
            Swift.print(controls.map(\.label))
            undoManager?.registerUndo(withTarget: self, handler: { document in
                document.controls = oldValue
            })
            
            controlsPublisher.send(controls)
        }
    }

    // MARK: - Constructors
    public convenience init(fileName: String,
                            rootPath: URL = iCloudContainer) {
        let file = rootPath.appendingPathComponent(fileName).appendingPathExtension(Self.vodesign)
        
        self.init(file: file)
        
        fileType = Self.vodesign
    }
    
    private lazy var documentSaveService = DocumentSaveService(fileURL: fileURL!.appendingPathComponent("controls.json"))
    
    public convenience init(file: URL) {
        do {
            try self.init(contentsOf: file,
                          ofType: Self.vodesign)
        } catch let error {
            Swift.print(error)
            // TODO: Is it ok?
            try! self.init(type: Self.vodesign)
        }
    }
    
    public convenience init(image: NSImage) {
        self.init(fileName: image.name() ?? Date().description)
        self.image = image
    }
    
    // MARK: - File managment
    
    public override class var autosavesInPlace: Bool {
        return true
    }
    
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
    
    private func controlsWrapper() throws -> FileWrapper {
        let wrapper = FileWrapper(regularFileWithContents: try documentSaveService.data(from: controls))
        wrapper.preferredFilename = "controls.json"
        return wrapper
    }
    
    private func imageWrapper() -> FileWrapper? {
        guard let image = image,
           let imageData = ImageSaveService().UIImagePNGRepresentation(image)
        else { return nil }
        
        let imageWrapper = FileWrapper(regularFileWithContents: imageData)
        imageWrapper.preferredFilename = "screen.png"
            
        return imageWrapper
    }
    
    private func previewWrapper() -> FileWrapper? {
        guard let image = image,
            let imageData = ImageSaveService().UIImagePNGRepresentation(image)
        else { return nil }
        
        let imageWrapper = FileWrapper(regularFileWithContents: imageData)
        imageWrapper.preferredFilename = QuickLookFileName
        
        let quicklookFolder = FileWrapper(directoryWithFileWrappers: [QuickLookFolderName: imageWrapper])
        quicklookFolder.preferredFilename = QuickLookFolderName
        return quicklookFolder
    }
    
    public override func read(from url: URL, ofType typeName: String) throws {
        Swift.print("Read from \(url)")
        
        controls = try documentSaveService.loadControls()
        
        image = try? ImageSaveService().load(from: url)
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
        fileType = Self.uti
        return super.writableTypes(for: saveOperation)
    }
    public override func prepareSavePanel(_ savePanel: NSSavePanel) -> Bool {
        
        savePanel.isExtensionHidden = false
        return true
    }
    
}
#endif

