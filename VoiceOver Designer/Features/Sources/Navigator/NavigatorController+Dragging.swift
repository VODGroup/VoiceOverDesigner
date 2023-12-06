import AppKit
import Document

let REORDER_PASTEBOARD_TYPE = NSPasteboard.PasteboardType(rawValue: "com.akaDuality.VoiceOver-Designer")

extension NavigatorController {
    
    func enableDragging() {
        // Register for the dropped object types we can accept.
        outlineView.registerForDraggedTypes([REORDER_PASTEBOARD_TYPE])
        
        // Disable dragging items from our view to other applications.
        outlineView.setDraggingSourceOperationMask(NSDragOperation(), forLocal: false)
        
        // Enable dragging items within and into our view.
        outlineView.setDraggingSourceOperationMask(NSDragOperation.every, forLocal: true)
    }
    
    public func outlineView(
        _ outlineView: NSOutlineView,
        pasteboardWriterForItem item: Any
    ) -> NSPasteboardWriting? {
        let pbItem:NSPasteboardItem = NSPasteboardItem()
        pbItem.setDataProvider(self, forTypes: [REORDER_PASTEBOARD_TYPE])
        return pbItem
    }
    
    public func outlineView(
        _ outlineView: NSOutlineView, draggingSession session: NSDraggingSession,
        willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]
    ) {
        draggedNode = draggedItems[0] as? any ArtboardElement
        session.draggingPasteboard.setData(Data(), forType: REORDER_PASTEBOARD_TYPE)
    }
    
    public func outlineView(
        _ outlineView: NSOutlineView,
        validateDrop info: NSDraggingInfo,
        proposedItem item: Any?, 
        proposedChildIndex index: Int
    ) -> NSDragOperation {
        let canDrag = presenter
            .canDrag(draggedNode!,
                     over: item as? (any ArtboardElement),
                     insertionIndex: index)
        return canDrag ? .move : []
    }
    
    public func outlineView(
        _ outlineView: NSOutlineView,
        acceptDrop info: NSDraggingInfo,
        item: Any?,
        childIndex toIndex: Int
    ) -> Bool {
        defer { outlineView.reloadData() }
        
        // TODO: Make animated reload
//        outlineView.moveItem(at: fromIndex, inParent: nil,
//                             to: toIndex, inParent: nil)
        
        return presenter.drag(
            draggedNode!,
            over: item as? (any ArtboardElement),
            insertAtIndex: toIndex)
    }
    
    public func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        self.draggedNode = nil
    }
}

extension NavigatorController: NSPasteboardItemDataProvider {
    public func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: NSPasteboard.PasteboardType) {
        let s = "Outline Pasteboard Item"
        item.setString(s, forType: type)
    }
}
