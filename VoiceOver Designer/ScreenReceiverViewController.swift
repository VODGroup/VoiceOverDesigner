//
//  ScreenReceiverViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import AppKit
import Document

class ScreenReceiverViewController: NSViewController {
    
    @IBAction func selectMenu(_ sender: Any) {
        show(with: NSImage(named: "Sample_menu")!)
    }
    
    @IBAction func selectProductCard(_ sender: Any) {
        show(with: NSImage(named: "Sample_product")!)
    }
    
    func show(with image: NSImage) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: "editor") as! EditorViewController
        
        controller.presenter.document = VODesignDocument(image: image)
        
        // VODesignDocument(fileName: "Test")
        
        view.window?.contentViewController = controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view().delegate = self
    }
    
    func view() -> ScreenReceiverView {
        view as! ScreenReceiverView
    }
}

extension ScreenReceiverViewController: DragNDropDelegate {
    func didDrag(image: NSImage) {
        show(with: image)
    }
}

protocol DragNDropDelegate: AnyObject {
    func didDrag(image: NSImage)
}

class ScreenReceiverView: NSView {
    
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

extension VODesignDocument {
    convenience init(image: NSImage) {
        self.init(fileName: image.name() ?? Date().description)
        self.image = image
    }
}
