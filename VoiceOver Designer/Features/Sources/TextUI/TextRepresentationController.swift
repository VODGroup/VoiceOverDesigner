import AppKit
import Document
import Combine

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
    
    public func select(_ model: A11yDescription?) {
        guard let index = document.controls.firstIndex(where: { aModel in
            aModel === model
        }) else { return }
        
        outlineView.selectRowIndexes(IndexSet(integer: index),
                                     byExtendingSelection: false)
    }
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    func inject(document: VODesignDocument, actionDelegate: TextRepresentationControllerDelegate?) {
        self.document = document
        self.actionDelegate = actionDelegate
    }
    
    private weak var actionDelegate: TextRepresentationControllerDelegate?
    private var document: VODesignDocument!
    
    private var draggedNode: A11yDescription? = nil
    
    private var cancellables = [AnyCancellable]()
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register for the dropped object types we can accept.
        outlineView.registerForDraggedTypes([REORDER_PASTEBOARD_TYPE])
        
        // Disable dragging items from our view to other applications.
        outlineView.setDraggingSourceOperationMask(NSDragOperation(), forLocal: false)
        
        // Enable dragging items within and into our view.
        outlineView.setDraggingSourceOperationMask(NSDragOperation.every, forLocal: true)
        
        document.controlsPublisher.sink { controls in
            self.outlineView.reloadData()
        }.store(in: &cancellables)
    }
}

let REORDER_PASTEBOARD_TYPE = NSPasteboard.PasteboardType(rawValue: "com.kinematicsystems.outline.item")

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

// MARK: Reordering

extension TextRepresentationController {
    public func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let pbItem:NSPasteboardItem = NSPasteboardItem()
        pbItem.setDataProvider(self, forTypes: [REORDER_PASTEBOARD_TYPE])
        return pbItem
    }
    
    public func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
        draggedNode = draggedItems[0] as? A11yDescription
        session.draggingPasteboard.setData(Data(), forType: REORDER_PASTEBOARD_TYPE)
    }
    
    public func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        return .move
    }
    
    public func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex toIndex: Int) -> Bool {
        guard toIndex != NSOutlineViewDropOnItemIndex else { return false } // When place over item, check `item` for this case. Will help lately when deal with container
        
        guard document.controls.move(draggedNode!, to: toIndex) else {
            print("did not move to \(toIndex)")
            return false
            
        }
        
//        outlineView.moveItem(at: fromIndex, inParent: nil,
//                             to: toIndex, inParent: nil)
        outlineView.reloadData()
        
        return true
    }
    
    public func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        self.draggedNode = nil
    }
}

extension TextRepresentationController: NSPasteboardItemDataProvider {
    public func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: NSPasteboard.PasteboardType) {
        let s = "Outline Pasteboard Item"
        item.setString(s, forType: type)
    }
}
