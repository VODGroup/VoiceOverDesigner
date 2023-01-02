#if os(iOS)
import UIKit
public typealias Document = UIDocument
import Combine

public class VODesignDocument: Document, VODesignDocumentProtocol {
    
    // MARK: - Data
    public var controls: [any AccessibilityView] = []
    public var image: Image?
    
    // MARK: -
    
    public var undo: UndoManager? {
        undoManager
    }
    
    public convenience init(fileName: String,
                            rootPath: URL = iCloudContainer) {
        let dir = rootPath.appendingPathComponent(fileName)
        do {
            let content = try FileManager.default
                .contentsOfDirectory(
                    atPath: dir.path)
        } catch let error {
            print("Can't read \(rootPath), error: \(error)")
        }
        
        self.init(fileURL: dir)
    }
    
    lazy var saveService: DocumentSaveService = DocumentSaveService(fileURL: fileURL
        .appendingPathComponent("controls.json"))
    
    public func read(then completion: @escaping () -> Void) throws {
        performAsynchronousFileAccess {
            let fileCoordinator = NSFileCoordinator(filePresenter: self)
            fileCoordinator.coordinate(
                readingItemAt: self.fileURL.appendingPathComponent("controls.json"),
                options: .withoutChanges,
                error: nil) { url in
                self.controls = try! DocumentSaveService(fileURL: url).loadControls()
                
                DispatchQueue.main.async(execute: completion)
            }
        }
    }
    
    // MARK: - Override
    // TODO: AppKit version uses filewrappers. Extract and reuse them?
    public override func save(to url: URL, for saveOperation: Document.SaveOperation) async -> Bool {
        do {
            try saveService.save(controls: controls)
            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    public override func read(from url: URL) throws {
        controls = try saveService.loadControls()
        image = try? ImageSaveService().load(from: url)
    }
}

extension UIDocument {
    public func printState() {
        if documentState == .normal {
            print("documentState: [normal]" )
        }
        var readableStrings = [String]()
        if documentState.contains(.inConflict) {
            readableStrings.append("inConflict")
        }
        if documentState.contains(.editingDisabled) {
            readableStrings.append("editingDisabled")
        }
        if documentState.contains(.progressAvailable) {
            readableStrings.append("progressAvailable")
        }
        if documentState.contains(.savingError) {
            readableStrings.append("savingError")
        }
        if documentState.contains(.closed) {
            readableStrings.append("closed")
        }
        print("documentState: \(readableStrings)")
    }
}
#endif
