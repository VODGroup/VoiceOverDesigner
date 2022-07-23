#if os(macOS)
// MARK: - AppKit
import AppKit
public typealias Document = NSDocument
import os

public class VODesignDocument: Document {
    public static var vodesign = "vodesign"
    
    // MARK: - Data
    public var image: NSImage?
    
    public var controls: [A11yDescription] = [] {
        didSet {
            undoManager?.registerUndo(withTarget: self, handler: { document in
                document.controls = oldValue
            })
        }
    }

    // MARK: - Constructors
    public convenience init(fileName: String,
                            rootPath: URL = iCloudContainer) {
        let file = rootPath.appendingPathComponent(fileName).appendingPathExtension(Self.vodesign)
        
        self.init(file: file)
        
        fileType = Self.vodesign
    }
    
    public convenience init(file: URL) {
        do {
            try self.init(contentsOf: file,
                          ofType: Self.vodesign)
        } catch let error {
            Swift.print(error)
            // TODO: Is it ok?
            try! self.init(type: Self.vodesign)
            self.fileURL = file
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
        let package = FileWrapper(directoryWithFileWrappers: [:])
        
        package.addFileWrapper(try controlsWrapper())
        
        if let imageWrapper = imageWrapper() {
            package.addFileWrapper(imageWrapper)
        }
     
        return package
    }
    
    private func controlsWrapper() throws -> FileWrapper {
        let wrapper = FileWrapper(regularFileWithContents: try JSONEncoder().encode(controls))
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
    
    public override func read(from url: URL, ofType typeName: String) throws {
        Swift.print("Read from \(url)")
        
        controls = try DocumentSaveService(fileURL: url.appendingPathComponent("controls.json")).loadControls()
        
        image = try? ImageSaveService().load(from: url)
    }
    
    public static func image(from url: URL) -> NSImage? {
        try? ImageSaveService().load(from: url)
    }
}
#endif
