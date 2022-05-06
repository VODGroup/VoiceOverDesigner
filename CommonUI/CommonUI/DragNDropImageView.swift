//
//  DragNDropImageView.swift
//  Projects
//
//  Created by Mikhail Rubanov on 06.05.2022.
//

import AppKit

public protocol DragNDropDelegate: AnyObject {
    func didDrag(image: NSImage)
    func didDrag(path: URL)
}

open class DragNDropImageView: NSView {
    open var isWaitingForFile: Bool = false
    
    public weak var delegate: DragNDropDelegate?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        // TODO: Add another files
        registerForDraggedTypes([.png, .fileURL])
    }
    
    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        isWaitingForFile = true
        return .copy
    }
    
    open override func draggingEnded(_ sender: NSDraggingInfo) {
        isWaitingForFile = false
    }
    
    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        
        if let image = NSImage(pasteboard: pasteboard) {
            delegate?.didDrag(image: image)
            return true
        }
        
        if let item = pasteboard.pasteboardItems?.first,
           let data = item.data(forType: .fileURL),
           let string = String(data: data, encoding: .utf8) {
            let url = URL(fileURLWithPath: string)
            delegate?.didDrag(path: url)
        }
        
        return false
    }
    
    open override func hitTest(_ point: NSPoint) -> NSView? {
        return nil // Translucent
    }
}
