//
//  ViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Cocoa

class EditorViewController: NSViewController {

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
            self.loadAndDraw()
        }
        
    }
    
    private func loadAndDraw() {
        do {
            let controls = try documentSaveService.loadControls()
            controls.forEach(drawingService.drawControl(from:))
        } catch let error {
            print(error)
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func showSettings(for control: A11yControl) {
        let storyboard = NSStoryboard(name: "Main", bundle: Bundle(for: SettingsViewController.self))
        let settings = storyboard.instantiateController(withIdentifier: .init("settings")) as! SettingsViewController
        settings.control = control
        settings.delegate = self
        
        present(settings,
                asPopoverRelativeTo: control.frame,
                of: view,
                preferredEdge: .maxX,
                behavior: .semitransient)
    }
    
    // MARK:
    override func mouseDown(with event: NSEvent) {
        if let existedControl = drawingService.control(at: event.locationInWindow) {
            showSettings(for: existedControl)
        } else {
            drawingService.start(coordinate: event.locationInWindow)
            
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        drawingService.drag(to: event.locationInWindow)
    }
    
    override func mouseUp(with event: NSEvent) {
        drawingService
            .end(coordinate: event.locationInWindow)
        
        save()
    }
    
    lazy var drawingService = DrawingService(view: view)
    let documentSaveService = DocumentSaveService()
    
    func view() -> EditorView {
        view as! EditorView
    }
}

extension EditorViewController: SettingsDelegate {
    func didUpdateValue() {
        save()
    }
    
    func delete(control: A11yControl) {
        drawingService.delete(control: control)
        save()
    }
    
    fileprivate func save() {
        documentSaveService.save(controls: drawingService.drawnControls)
    }
}

extension CALayer {
    public func updateWithoutAnimation(_ block: () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        block()
        CATransaction.commit()
    }
}

class EditorView: NSView {
    @IBOutlet weak var scrollView: NSScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.magnification = 3
    }
}

