//
//  ProjectsView.swift
//  Projects
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit

protocol DragNDropDelegate: AnyObject {
    func didDrag(image: NSImage)
}

class ProjectsView: NSView {
    
    weak var delegate: DragNDropDelegate?
    
    @IBOutlet weak var dragHereView: NSImageView!
    @IBOutlet weak var dragHereLabel: NSTextField!
    
    private var isWaitingForFile: Bool = false {
        didSet {
            dragHereView.isHidden = !isWaitingForFile
            dragHereLabel.isHidden = isWaitingForFile
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // TODO: Add another files
        registerForDraggedTypes([.png, .fileURL, .fileContents])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        isWaitingForFile = true
        return .copy
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        isWaitingForFile = false
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        
        guard let image = NSImage(pasteboard: pasteboard) else { return false }
        
        delegate?.didDrag(image: image)
        
        return true
    }
}
