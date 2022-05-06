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
        
        do {
            try self.init(contentsOf: file,
                          ofType: Self.vodesign)
        } catch let error {
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
        save(to: fileURL!, ofType: "", for: .saveOperation) { error in
            Swift.print(error)
            // TODO: Handle
        }
    }
    
    public func read() {
        // TODO: Try
        try? read(from: fileURL!, ofType: Self.vodesign)
    }
    
    public override func write(to url: URL, ofType typeName: String) throws {
        Swift.print("Save to \(url)")
        
        try FileManager.default.createDirectory(at: url,
                                                withIntermediateDirectories: true)
        DocumentSaveService(fileURL: url.appendingPathComponent("controls.json"))
            .save(controls: self.controls)

        if let image = self.image {
            try ImageSaveService().save(image: image, to: url.deletingLastPathComponent())
        }
    }
    
    public override func read(from url: URL, ofType typeName: String) throws {
        Swift.print("Read from \(fileURL)")
        
        controls = try DocumentSaveService(fileURL: url.appendingPathComponent("controls.json")).loadControls()
        
        image = try? imageSaveService.load(from: url)
    }
    
//    public override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
//
//        os_log("start saving")
//        performAsynchronousFileAccess { completion in
//            let fileCoordinator = NSFileCoordinator(filePresenter: self)
//            fileCoordinator.coordinate(
//                writingItemAt: url.appendingPathComponent("controls.json"),
//                options: .forReplacing,
//                error: nil
//            ) { url in
//                os_log("got access")
//                do {
//                    self.fileModificationDate = Date()
//                    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
//                                                            withIntermediateDirectories: true)
//                    DocumentSaveService(fileURL: url).save(controls: self.controls)
//
//                    if let image = self.image {
//                        try ImageSaveService().save(image: image, to: url.deletingLastPathComponent())
//                    }
//
//                    completionHandler(nil)
//                    completion()
//                    os_log("save")
//                } catch let error {
//                    completionHandler(error)
//                    os_log("fail saving")
//                    completion()
//                }
//            }
//        }
//    }
    
    private let imageSaveService = ImageSaveService()
}
#endif

