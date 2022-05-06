#if os(macOS)
// MARK: - AppKit
import AppKit
public typealias Document = NSDocument
import os

public class VODesignDocument: Document {
    public var image: NSImage?
    public var controls: [A11yDescription] = []
    let name = "Test"
    
    public static var vodesign = "vodesign"
    
    public convenience init(fileName: String,
                            rootPath: URL = iCloudContainer) {
        let file = rootPath.appendingPathComponent(fileName).appendingPathExtension(Self.vodesign)
        
        self.init(file: file)
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
    
    public func save() {
        save(to: fileURL!, ofType: Self.vodesign, for: .saveOperation) { error in
            Swift.print(error)
            // TODO: Handle
        }
    }
    
    public func read() throws {
        try read(from: fileURL!, ofType: Self.vodesign)
    }
    
    public override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        let package = FileWrapper(
            directoryWithFileWrappers:
                ["controls.json" : FileWrapper(
                    regularFileWithContents: try JSONEncoder().encode(controls)),
                ]
        )
        
        if let image = image,
            let imageData = ImageSaveService().UIImagePNGRepresentation(image)
        {
            let imageWrapper = FileWrapper(regularFileWithContents: imageData)
            imageWrapper.preferredFilename = "screen.png"
                                           
            package.addFileWrapper(imageWrapper)
        }
     
        return package
    }
    
    public override class var autosavesInPlace: Bool {
        return true
    }
    
    public override func read(from url: URL, ofType typeName: String) throws {
        Swift.print("Read from \(url)")
        
        controls = try DocumentSaveService(fileURL: url.appendingPathComponent("controls.json")).loadControls()
        
        image = try? imageSaveService.load(from: url)
    }
    
    private let imageSaveService = ImageSaveService()
}
#endif

