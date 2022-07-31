import AppKit

class TextRepresentationController: NSViewController {
    
    public static func fromStoryboard() -> TextRepresentationController {
        NSStoryboard(name: "TextRepresentationController", bundle: nil).instantiateInitialController() as! TextRepresentationController
    }
    
}

extension TextRepresentationController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        5
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     child index: Int,
                     ofItem item: Any?
    ) -> Any {
        return "Text"
    }
}

extension TextRepresentationController: NSOutlineViewDelegate {
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let id = NSUserInterfaceItemIdentifier("Element")
        
        let view = outlineView.makeView(withIdentifier: id, owner: self) as! NSTableCellView
        view.textField?.stringValue = "Text"
        return view
    }
}
