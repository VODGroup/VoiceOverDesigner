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
    
    public func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let pbItem:NSPasteboardItem = NSPasteboardItem()
        pbItem.setDataProvider(self, forTypes: [REORDER_PASTEBOARD_TYPE])
        return pbItem
    }
    
    public func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
        draggedNode = draggedItems[0] as? any ArtboardElement
        session.draggingPasteboard.setData(Data(), forType: REORDER_PASTEBOARD_TYPE)
    }
    
    public func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        return .move
    }
    
    public func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex toIndex: Int) -> Bool {
        if toIndex == NSOutlineViewDropOnItemIndex,
           let onElement = item as? any ArtboardElement {

            document.controls.wrapInContainer(
                [draggedNode!, onElement].extractElements(),
                label: "Container")
            
            outlineView.reloadData()
            
            return true
        } else if let element = draggedNode as? A11yDescription {
            
            let currentParent = outlineView.parent(forItem: draggedNode) as? A11yContainer
            
            document.controls.move(element, fromContainer: currentParent,
                                   toIndex: toIndex, toContainer: item as? A11yContainer)
            
            outlineView.reloadData()
            return true
        } else if let container = draggedNode as? A11yContainer, item == nil {
            let didMove = document.controls.move(container, to: toIndex)
            outlineView.reloadData()
            return didMove
        }
        
        // TODO: Make animated reload
        //        outlineView.moveItem(at: fromIndex, inParent: nil,
        //                             to: toIndex, inParent: nil)
        
        return false
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
