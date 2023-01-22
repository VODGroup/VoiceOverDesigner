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
        self.image = image
    }
    
    // MARK: - Override
    
    public override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        Swift.print("Will save")
        
        let framePackage = FileWrapper(directoryWithFileWrappers: [:])
        framePackage.preferredFilename = defaultFrameName
        
        framePackage.addFileWrapper(try controlsWrapper())
        
        if let imageWrapper = imageWrapper() {
            framePackage.addFileWrapper(imageWrapper)
        }
        
        let frameMetaData = try! FrameInfoPersistance.data(frame: frameInfo)
        let frameMetaWrapper = FileWrapper(regularFileWithContents: frameMetaData)
        frameMetaWrapper.preferredFilename = FileName.info
        framePackage.addFileWrapper(frameMetaWrapper)
        
        let package = FileWrapper(directoryWithFileWrappers: [:])
        package.addFileWrapper(framePackage)
        
        if let previewWrapper = previewWrapper() {
            package.addFileWrapper(previewWrapper)
        }
        
        return package
    }
    
    public override func read(from url: URL, ofType typeName: String) throws {
        Swift.print("Read from \(url)")
        
        undoManager?.disableUndoRegistration()
        defer { undoManager?.enableUndoRegistration() }
        
        let frameReader = FrameReader(documentURL: url, frameName: defaultFrameName)
        
        controls = try frameReader.saveService.loadControls()
        image = try? frameReader.imageSaveService.load()
        frameInfo = frameReader.frameInfoPersistance
            .readFrame() ?? .default
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

// MARK: - File wrappers
extension VODesignDocument {
    private func controlsWrapper() throws -> FileWrapper {
        let codingService = AccessibilityViewCodingService()
        let wrapper = FileWrapper(regularFileWithContents: try codingService.data(from: controls))
        wrapper.preferredFilename = FileName.controls
        return wrapper
    }
    
    private func imageWrapper() -> FileWrapper? {
        guard let image = image,
              let imageData = image.png()
        else { return nil }
        
        let imageWrapper = FileWrapper(regularFileWithContents: imageData)
        imageWrapper.preferredFilename = FileName.screen
        
        
        return imageWrapper
    }
    
    private func previewWrapper() -> FileWrapper? {
        guard let image = image, // TODO: Make smaller size
              let imageData = image.png()
        else { return nil }
        
        let imageWrapper = FileWrapper(regularFileWithContents: imageData)
        imageWrapper.preferredFilename = QuickLookFileName
        
        let quicklookFolder = FileWrapper(directoryWithFileWrappers: [QuickLookFolderName: imageWrapper])
        quicklookFolder.preferredFilename = QuickLookFolderName
        return quicklookFolder
    }
    
}
#endif
