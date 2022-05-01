#if canImport(UIKit)
import UIKit
public typealias Document = UIDocument


public class VODesignDocument: Document {
    public var controls: [A11yDescription] = []
    
    lazy var saveService: DocumentSaveService = DocumentSaveService(fileURL: fileURL)
    
    public override func save(to url: URL, for saveOperation: Document.SaveOperation) async -> Bool {
        
        do {
            controls = try DocumentSaveService(fileURL: url).loadControls()
            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    public override func read(from url: URL) throws {
        DocumentSaveService(fileURL: url).save(controls: controls)
    }
}

#else
import AppKit
public typealias Document = NSDocument

public class VODesignDocument: Document {
    var image: NSImage?
    public var controls: [A11yDescription] = []
    let name = "Test"
    
    static var fileExtension = "vodesign"
    
    public convenience init(fileName: String) {
        let url = FileManager.default
            .url(forUbiquityContainerIdentifier: nil)!
            .appendingPathComponent("Documents")
        
        let file = url.appendingPathComponent(fileName)
        
        do {
            try self.init(contentsOf: file,
                          ofType: Self.fileExtension)
        } catch let error {
            // TODO: Is it ok?
            try! self.init(type: Self.fileExtension)
            self.fileURL = file
        }
    }
    
    public func save() {
        save(to: fileURL!, ofType: "", for: .saveOperation) { error in
            Swift.print(error)
            // TODO: Handle
        }
    }
    
    public func read() {
        // TODO: Try
        try? read(from: fileURL!, ofType: Self.fileExtension)
    }
    
    public static let iCloudSample = FileManager.default
        .url(forUbiquityContainerIdentifier: nil)!
        .appendingPathComponent("Documents")
    
    lazy var saveService: DocumentSaveService = DocumentSaveService(fileURL: fileURL!)
    
    public override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            DocumentSaveService(fileURL: url).save(controls: controls)
            
            if let image = image {
                try ImageSaveService(image: image).save(to: url)
            }
            
            completionHandler(nil)
        } catch let error {
            completionHandler(error)
        }
    }
    
    public override func read(from url: URL, ofType typeName: String) throws {
        
        controls = try DocumentSaveService(fileURL: url).loadControls()
    }
}
#endif

