#if canImport(UIKit)
import UIKit
public typealias Document = UIDocument


public class VODesignDocument: Document {
    var controls: [A11yDescription] = []
    
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
    var controls: [A11yDescription] = []
    
    lazy var saveService: DocumentSaveService = DocumentSaveService(fileURL: fileURL!)
    
    public override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
        do {
            controls = try DocumentSaveService(fileURL: url).loadControls()
            completionHandler(nil)
        } catch let error {
            Swift.print(error)
            completionHandler(error)
        }
    }
    
    public override func read(from url: URL, ofType typeName: String) throws {
        DocumentSaveService(fileURL: url).save(controls: controls)
    }
}
#endif

