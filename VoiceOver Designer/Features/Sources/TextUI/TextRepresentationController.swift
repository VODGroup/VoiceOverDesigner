import AppKit
import Document

public protocol TextRepresentationControllerDelegate: AnyObject {
    func didSelect(_ model: A11yDescription)
}

public class TextRepresentationController: NSViewController {
    
    public static func fromStoryboard(
        document: VODesignDocument,
        actionDelegate: TextRepresentationControllerDelegate?
    ) -> TextRepresentationController {
        let controller = NSStoryboard(
            name: "TextRepresentationController",
            bundle: Bundle.module).instantiateInitialController() as! TextRepresentationController
        
        controller.inject(
            document: document,
            actionDelegate: actionDelegate
        )
        
        return controller
    }
    
    func inject(document: VODesignDocument, actionDelegate: TextRepresentationControllerDelegate?) {
        self.document = document
        self.actionDelegate = actionDelegate
    }
    
    weak var actionDelegate: TextRepresentationControllerDelegate?
    private var document: VODesignDocument!
}

extension TextRepresentationController: NSOutlineViewDataSource {
    
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        document.controls.count
    }
    
    public func outlineView(_ outlineView: NSOutlineView,
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
    
    public func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else { return }
        
        if let model = outlineView.item(atRow: outlineView.selectedRow) as? A11yDescription {
            actionDelegate?.didSelect(model)
        }
    }
}
