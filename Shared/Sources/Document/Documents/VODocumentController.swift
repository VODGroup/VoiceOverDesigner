
#if canImport(AppKit)
import AppKit

public class VODocumentController: NSDocumentController {
    public override func documentClass(forType typeName: String) -> AnyClass? {
        return VODesignDocument.self
    }
    
    public override func removeDocument(_ document: NSDocument) {
        super.removeDocument(document)
        
    }
}
#endif
