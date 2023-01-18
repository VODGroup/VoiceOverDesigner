#if os(macOS)
// MARK: - AppKit
import AppKit
public typealias Document = NSDocument

import os

public let vodesign = "vodesign"
public let uti = "com.akaDuality.vodesign"
import QuickLookThumbnailing

public class VODesignDocument: Document, VODesignDocumentProtocol {

    // MARK: - Data
    public var image: Image?
    public var imageSize: CGSize {
        guard let image else { return .zero }
        
        return image.size
    }
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
        
        
        if let imageWrapper = imageWrapper(), let previewWrapper = previewWrapper() {
            package.addFileWrapper(imageWrapper)
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
    
    public static func image(from url: URL) async -> Image? {
        try? ImageSaveService().load(from: url)
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
              let imageData = imageService.UIImagePNGRepresentation(image)
        else { return nil }
        
        let imageWrapper = FileWrapper(regularFileWithContents: imageData)
        imageWrapper.preferredFilename = "screen.png"
        
        
        return imageWrapper
    }
    
    private func previewWrapper() -> FileWrapper? {
        guard let image = image,
              let imageData = imageService.UIImagePNGRepresentation(image)
        else { return nil }
        
        let imageWrapper = FileWrapper(regularFileWithContents: imageData)
        imageWrapper.preferredFilename = QuickLookFileName
        
        let quicklookFolder = FileWrapper(directoryWithFileWrappers: [QuickLookFolderName: imageWrapper])
        quicklookFolder.preferredFilename = QuickLookFolderName
        return quicklookFolder
    }
    
}
#endif

import Foundation
import QuickLookThumbnailing
public extension URL {
    var fileName: String {
        deletingPathExtension().lastPathComponent
    }
}

public class ThumbnailDocument {
    
    public init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    private var fileURL: URL
    
    private var thumbnailCache: Image?
    public func thumbnail(size: CGSize, scale: CGFloat) async -> Image? {
        if let thumbnailCache {
            // TODO: Invalidate cache if other size is requested
            return thumbnailCache
        }
        
        let imagePath = ImageSaveService().imagePath(documentURL: fileURL)
        let request = QLThumbnailGenerator.Request(
            fileAt: imagePath,
            size: size,
            scale: scale,
            representationTypes: .thumbnail)
        
        let previewGenerator = QLThumbnailGenerator()
        let thumbnail = try? await previewGenerator.generateBestRepresentation(for: request)
        
        #if canImport(AppKit)
        thumbnailCache = thumbnail?.nsImage
        return thumbnail?.nsImage
        #else
        thumbnailCache = thumbnail?.uiImage
        return thumbnail?.uiImage
        #endif
    }
}
