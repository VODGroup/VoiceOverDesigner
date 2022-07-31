import AppKit
import Document

class TextRepresentationController: NSViewController {
    
    public static func fromStoryboard(
        document: VODesignDocument
    ) -> TextRepresentationController {
        let controller = NSStoryboard(
            name: "TextRepresentationController",
            bundle: nil).instantiateInitialController() as! TextRepresentationController
        
        controller.inject(document: document)
        
        return controller
    }
    
    public func inject(document: VODesignDocument) {
        self.document = document
    }
    
    private var document: VODesignDocument!
}

extension TextRepresentationController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        document.controls.count
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     child index: Int,
                     ofItem item: Any?
    ) -> Any {
        document.controls[index]
    }
}

extension TextRepresentationController: NSOutlineViewDelegate {
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let control = item as? A11yDescription else {
            return nil
        }
        
        let id = NSUserInterfaceItemIdentifier("Element")
        
        let view = outlineView.makeView(withIdentifier: id, owner: self) as! NSTableCellView
        view.textField?.stringValue = control.voiceOverText
        return view
    }
}
