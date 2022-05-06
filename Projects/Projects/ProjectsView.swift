//
//  ProjectsView.swift
//  Projects
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit

protocol DragNDropDelegate: AnyObject {
    func didDrag(image: NSImage)
    func didDrag(path: URL)
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
        registerForDraggedTypes([.png, .fileURL, .fileContents, .URL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        isWaitingForFile = true
        return .copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isWaitingForFile = false
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
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
}
