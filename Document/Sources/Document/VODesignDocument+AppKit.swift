#if os(macOS)
// MARK: - AppKit
import AppKit
public typealias Document = NSDocument
import os

public class VODesignDocument: Document {
    var image: NSImage?
    public var controls: [A11yDescription] = []
    let name = "Test"
    
    static var fileExtension = "vodesign"
    
    public convenience init(fileName: String,
                            rootPath: URL = iCloudContainer) {
        let file = rootPath.appendingPathComponent(fileName)
        
        do {
            try self.init(contentsOf: file,
                          ofType: Self.fileExtension)
        } catch let error {
            // TODO: Is it ok?
            try! self.init(type: Self.fileExtension)
            self.fileURL = file
        }
    }
    
    public override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
        
        os_log("start saving")
        performAsynchronousFileAccess { completion in
            let fileCoordinator = NSFileCoordinator(filePresenter: self)
            fileCoordinator.coordinate(
                writingItemAt: url.appendingPathComponent("controls.json"),
                options: .forReplacing,
                error: nil
            ) { url in
                os_log("got access")
                do {
                    self.fileModificationDate = Date()
                    //                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                    DocumentSaveService(fileURL: url).save(controls: self.controls)
                    
                    if let image = self.image {
                        try ImageSaveService(image: image).save(to: url)
                    }
                    
                    completionHandler(nil)
                    completion()
                    os_log("save")
                } catch let error {
                    completionHandler(error)
                    os_log("fail saving")
                    completion()
                }
            }
        }
    }
    
    public override func read(from url: URL, ofType typeName: String) throws {
        controls = try DocumentSaveService(fileURL: url.appendingPathComponent("controls.json")).loadControls()
    }
}
#endif

