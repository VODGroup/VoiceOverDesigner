//
//  ViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Cocoa
import Document

public class EditorViewController: NSViewController {

    public let presenter = EditorPresenter()
    
    var trackingArea: NSTrackingArea!
    
    public override func viewDidLoad() {
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
    
    public override func viewDidAppear() {
        super.viewDidAppear()
        
        DispatchQueue.main.async {
            self.presenter.didLoad(
                ui: self.view().controlsView,
                controller: self)
            self.setImage()
        }
    }
    
    func setImage() {
        let image = presenter.document.image
        view().backgroundImageView.frame = CGRect(x: 0, y: 0, width: 375, height: 1000)
        view().backgroundImageView.image = image
        view().backgroundImageView.layer?.zPosition = 0
        view.window?.contentMinSize = CGSize(width: 320, height: 762)
    }
    
    public override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    var highlightedControl: A11yControl? {
        didSet {
            if let highlightedControl = highlightedControl {
                NSCursor.openHand.push()
            } else {
                NSCursor.openHand.pop()
            }
        }
    }
    public override func mouseMoved(with event: NSEvent) {
        highlightedControl?.isHiglighted = false
        highlightedControl = nil
        
        guard let control = presenter.drawingService.control(at: event.locationInWindowFlipped) else {
            return
        }
        
        self.highlightedControl = control
        
        control.isHiglighted = true
        
        
//        NSCursor.current.set = NSImage(
//            systemSymbolName: "arrow.up.and.down.and.arrow.left.and.right",
//            accessibilityDescription: nil)!
    }
    
    // MARK:
    public override func mouseDown(with event: NSEvent) {
        presenter.mouseDown(on: event.locationInWindowFlipped)
    }
    
    public override func mouseDragged(with event: NSEvent) {
        presenter.mouseDragged(on: event.locationInWindowFlipped)
    }
    
    public override func mouseUp(with event: NSEvent) {
        presenter.mouseUp(on: event.locationInWindowFlipped)
    }
    
    func view() -> EditorView {
        view as! EditorView
    }
    
    public static func fromStoryboard() -> EditorViewController {
        let storyboard = NSStoryboard(name: "Editor", bundle: Bundle(for: EditorViewController.self))
        return storyboard.instantiateInitialController() as! EditorViewController
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
    
    @IBOutlet weak var backgroundImageView: NSImageView!
    
    @IBOutlet weak var controlsView: NSView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.verticalScrollElasticity = .none
        scrollView.horizontalScrollElasticity = .none
    }
}

class FlippedView: NSView {
    override var isFlipped: Bool {
        get {
            true
        }
    }
}


