
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
#if DEBUG
        if !(inTypes?.isEmpty ?? true) {
            fatalError("Wow! open type fixed somehow. How did you fixed it? You can remove this error, just currios how it is fixed")
        }
#endif
        // By unknown reason `inTypes` parameter is empty that cause failing at NSSavePanel
        // Default type com.akaDuality.vodesign from Info.plist fixes this problem
        return await super.beginOpenPanel(openPanel, forTypes: [defaultType!])
    }
}
#endif
