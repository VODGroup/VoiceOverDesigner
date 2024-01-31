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

    @IBOutlet weak var dragndropHere: NSTextField?
    
    var text: String = "" {
        didSet {
            dragndropHere?.stringValue = text
            needsLayout = true
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        registerDragging()
    }
    
    // MARK: - Dragging
    func registerDragging() {
        // TODO: Add another files
        registerForDraggedTypes([.png, .fileURL])
    }
    
    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        isWaitingForFile = true
        show(text: NSLocalizedString("Drop!", comment: ""))
        return .copy
    }
    
    open override func draggingExited(_ sender: NSDraggingInfo?) {
        show(text: NSLocalizedString("Drag image here", comment: ""))
    }
    
    open override func draggingEnded(_ sender: NSDraggingInfo) {
        isWaitingForFile = false
    }
    
    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        
        if let image = NSImage(pasteboard: pasteboard) {
            delegate?.didDrag(image: image)
            hideText()
            return true
        }
        
        if let item = pasteboard.pasteboardItems?.first,
           let data = item.data(forType: .fileURL),
           let string = String(data: data, encoding: .utf8) {
            let url = URL(fileURLWithPath: string)
            delegate?.didDrag(path: url)
            hideText()
            return true
        }
        
        show(text: NSLocalizedString("Another time...", comment: ""),
             changeTo: defaultText)
        
        return false
    }
    
    let defaultText = NSLocalizedString("or Drag'n'Drop", comment: "")
    
    func show(text: String, changeTo nextText: String? = nil) {
        dragndropHere?.isHidden = false
        self.text = text
        
        if let nextText = nextText {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.text = nextText
            }
        }
    }
    
    func hideText() {
        dragndropHere?.isHidden = true
    }
}
