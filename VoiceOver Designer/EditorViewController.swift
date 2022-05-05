//
//  ViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Cocoa
import Document

class Router {
    init(rootController: NSViewController) {
        self.rootController = rootController
    }
    
    let rootController: NSViewController
     
    func showSettings(for control: A11yControl, delegate: SettingsDelegate) {
        let storyboard = NSStoryboard(name: "Main", bundle: Bundle(for: SettingsViewController.self))
        let settings = storyboard.instantiateController(withIdentifier: .init("settings")) as! SettingsViewController
        settings.control = control
        settings.delegate = delegate
        
        rootController.present(settings,
                               asPopoverRelativeTo: control.frame,
                               of: rootController.view,
                               preferredEdge: .maxX,
                               behavior: .semitransient)
    }
}

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
            document.read()
            document.controls.forEach(drawingService.drawControl(from:))
        } catch let error {
            print(error)
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK:
    override func mouseDown(with event: NSEvent) {
        if let existedControl = drawingService.control(at: event.locationInWindowFlipped) {
            router.showSettings(for: existedControl, delegate: self)
        } else {
            drawingService.start(coordinate: event.locationInWindowFlipped)
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        drawingService.drag(to: event.locationInWindowFlipped)
    }
    
    override func mouseUp(with event: NSEvent) {
        drawingService
            .end(coordinate: event.locationInWindowFlipped)
        
        save()
    }
    
    lazy var router = Router(rootController: self)
    lazy var drawingService = DrawingService(view: view)
    let document = VODesignDocument(fileName: "Test")
    
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

extension EditorViewController: SettingsDelegate {
    func didUpdateValue() {
        save()
    }
    
    func delete(control: A11yControl) {
        drawingService.delete(control: control)
        save()
    }
    
    fileprivate func save() {
        let descriptions = drawingService.drawnControls.compactMap { control in
            control.a11yDescription
        }
        
        document.controls = descriptions
        document.save()
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


