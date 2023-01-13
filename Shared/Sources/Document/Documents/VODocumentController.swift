
#if canImport(AppKit)
import AppKit

public class VODocumentController: NSDocumentController {
    public override func documentClass(forType typeName: String) -> AnyClass? {
        VODesignDocument.self
    }
    
    public override func removeDocument(_ document: NSDocument) {
        super.removeDocument(document)
        
    }
    
    public override func beginOpenPanel(_ openPanel: NSOpenPanel, forTypes inTypes: [String]?) async -> Int {
        // By unknown reason `inTypes` parameter is empty that cause failing at NSSavePanel
        // Default type com.akaDuality.vodesign from Info.plist fixes this problem
        await super.beginOpenPanel(openPanel, forTypes: [defaultType!])
    }
}
#endif
