import AppKit
import Document

let REORDER_PASTEBOARD_TYPE = NSPasteboard.PasteboardType(rawValue: "com.kinematicsystems.outline.item")

extension TextRepresentationController {
    
    func enableDragging() {
        // Register for the dropped object types we can accept.
        outlineView.registerForDraggedTypes([REORDER_PASTEBOARD_TYPE])
        
        // Disable dragging items from our view to other applications.
        outlineView.setDraggingSourceOperationMask(NSDragOperation(), forLocal: false)
        
        // Enable dragging items within and into our view.
        outlineView.setDraggingSourceOperationMask(NSDragOperation.every, forLocal: true)
    }
    
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
        
        guard let element = draggedNode else { return false }
        
        let currentParent = outlineView.parent(forItem: draggedNode) as? A11yContainer
        
//        document.controls.move(element, fromContainer: currentParent,
//                               toIndex: toIndex, toContainer: item as? A11yContainer)
        
        if let container = item as? A11yContainer {
            if let element = draggedNode {
                // Remove from list
                if let from = document.controls.firstIndex(where: { control in
                    control === element
                }) {
                    document.controls.remove(at: from)
                }

                // Insert in container
                container.elements.insert(element, at: toIndex)
                outlineView.reloadData()
                return true
            }
        }

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
