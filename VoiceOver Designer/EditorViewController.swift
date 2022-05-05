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

class EditorPresenter {
    
    let document = VODesignDocument(fileName: "Test")
    var drawingService: DrawingService!
    var router: Router!
    
    func didLoad(ui: NSView, controller: NSViewController) {
        drawingService = DrawingService(view: ui)
        router = Router(rootController: controller)
        
        loadAndDraw()
    }
    
    func loadAndDraw() {
        do {
            document.read()
            document.controls.forEach(drawingService.drawControl(from:))
        } catch let error {
            print(error)
        }
    }
    
    func save() {
        let descriptions = drawingService.drawnControls.compactMap { control in
            control.a11yDescription
        }
        
        document.controls = descriptions
        document.save()
    }
    
    func mouseDown(on location: CGPoint) {
        if let existedControl = drawingService.control(at: location) {
            router.showSettings(for: existedControl, delegate: self)
        } else {
            drawingService.start(coordinate: location)
        }
    }
    
    func mouseDragged(on location: CGPoint) {
        drawingService.drag(to: location)
    }
    
    func mouseUp(on location: CGPoint) {
        drawingService.end(coordinate: location)
        
        save()
    }
}

extension EditorPresenter: SettingsDelegate {
    func didUpdateValue() {
        save()
    }
    
    func delete(control: A11yControl) {
        drawingService.delete(control: control)
        save()
    }
}

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
        presenter.mouseDragged(on: event.locationInWindowFlipped)
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


