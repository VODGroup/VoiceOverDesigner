//
//  ViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Cocoa
import Document
import CommonUI

public class EditorViewController: NSViewController {

    public let presenter = EditorPresenter()
    
    var trackingArea: NSTrackingArea!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.window?.makeFirstResponder(self)
        
        view().dragnDropView.delegate = self
    }
    
    private func addMouseTracking() {
        trackingArea = NSTrackingArea(
            rect: view.bounds,
            options: [.activeAlways,
                      .mouseMoved,
                      .mouseEnteredAndExited,
                      .inVisibleRect],
            owner: self,
            userInfo: nil)
        view.addTrackingArea(trackingArea)
    }
    
    public override func viewDidAppear() {
        super.viewDidAppear()
        
        DispatchQueue.main.async {
            self.presenter.didLoad(
                ui: self.view().controlsView,
                router: Router(rootController: self))
            self.setImage()
            self.addMouseTracking()
        }
    }
    
    func setImage() {
        guard let image = presenter.document.image else { return }
        
        view().setImage(image)
    }
    
    public override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    var highlightedControl: A11yControl? {
        didSet {
            if highlightedControl != nil {
                NSCursor.openHand.push()
            } else {
                NSCursor.openHand.pop()
            }
        }
    }
    public override func mouseMoved(with event: NSEvent) {
        highlightedControl?.isHiglighted = false
        highlightedControl = nil
        
        // TODO: Can crash if happend before document loading
        guard let control = presenter.drawingService.control(at: location(from: event)) else {
            return
        }
        
        self.highlightedControl = control
        
        control.isHiglighted = true
        
        
//        NSCursor.current.set = NSImage(
//            systemSymbolName: "arrow.up.and.down.and.arrow.left.and.right",
//            accessibilityDescription: nil)!
    }
    
    func location(from event: NSEvent) -> CGPoint {
        let inWindow = event.locationInWindow
        let flipped = inWindow.flippendVertical(in: view)
        let inView = view().backgroundImageView.convert(flipped, from: view)
        return inView.flippendVertical(in: view().backgroundImageView)
    }
    
    
    // MARK:
    public override func mouseDown(with event: NSEvent) {
        presenter.mouseDown(on: location(from: event))
    }
    
    public override func mouseDragged(with event: NSEvent) {
        presenter.mouseDragged(on: location(from: event))
    }
    
    public override func mouseUp(with event: NSEvent) {
        presenter.mouseUp(on: location(from: event))
    }
    
    func view() -> EditorView {
        view as! EditorView
    }
    
    public static func fromStoryboard() -> EditorViewController {
        let storyboard = NSStoryboard(name: "Editor", bundle: Bundle(for: EditorViewController.self))
        return storyboard.instantiateInitialController() as! EditorViewController
    }
}

extension EditorViewController: DragNDropDelegate {
    public func didDrag(image: NSImage) {
        presenter.document.image = image
        view().backgroundImageView.image = image
        presenter.save()
    }
    
    public func didDrag(path: URL) {
        // TODO: Add support. Or decline this files
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

extension CGPoint {
    func flippendVertical(in view: NSView) -> CGPoint {
        CGPoint(x: x,
                y: view.frame.height - y
        )
    }
}
