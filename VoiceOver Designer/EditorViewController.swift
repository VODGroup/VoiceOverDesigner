//
//  ViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Cocoa
import Document

class EditorViewController: NSViewController {

    let presenter = EditorPresenter()
    
    var trackingArea: NSTrackingArea!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        trackingArea = NSTrackingArea(
            rect: view.bounds,
            options: [.activeAlways,
                      .mouseMoved,
                      .mouseEnteredAndExited,
                      .inVisibleRect],
            owner: self,
            userInfo: nil)
        view.addTrackingArea(trackingArea)
        
        view.window?.makeFirstResponder(self)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        DispatchQueue.main.async {
            self.presenter.didLoad(ui: self.view, controller: self)
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK:
    override func mouseDown(with event: NSEvent) {
        presenter.mouseDown(on: event.locationInWindowFlipped)
    }
    
    override func mouseDragged(with event: NSEvent) {
        presenter.mouseDragged(on: event.locationInWindowFlipped)
    }
    
    override func mouseUp(with event: NSEvent) {
        presenter.mouseUp(on: event.locationInWindowFlipped)
    }
    
    func view() -> EditorView {
        view as! EditorView
    }
}

extension NSEvent {
    var locationInWindowFlipped: CGPoint {
        return CGPoint(x: locationInWindow.x,
                       y: window!.frame.height
                       - locationInWindow.y
                       - 28 // TODO: Remove toolbar's height
        )
    }
}

class EditorView: FlippedView {
    @IBOutlet weak var scrollView: NSScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.magnification = 3
    }
}

class FlippedView: NSView {
    override var isFlipped: Bool {
        get {
            true
        }
    }
}


