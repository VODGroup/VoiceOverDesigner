//
//  EditorPresenter.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import Document
import AppKit
import Settings

public class EditorPresenter {
    
    public var document: VODesignDocument!
    var drawingController: DrawingController!
    var router: RouterProtocol!
    
    func didLoad(ui: NSView, router: RouterProtocol) {
        drawingController = DrawingController(view: ui)
        self.router = router
        
        draw()
    }
    
    func draw() {
        document.controls.forEach { control in
            drawingController.drawControl(from: control)
        }
    }
    
    func save() {
        let descriptions = drawingController.drawnControls.compactMap { control in
            control.a11yDescription
        }
        
        document.controls = descriptions
    }
    
    // MARK: Mouse
    func mouseDown(on location: CGPoint) {
        if let existedControl = drawingController.control(at: location) {
            drawingController.startTranslating(control: existedControl,
                                            startLocation: location)
        } else {
            drawingController.startDrawing(coordinate: location)
        }
    }
    
    func mouseDragged(on location: CGPoint) {
        drawingController.drag(to: location)
    }
    
    func mouseUp(on location: CGPoint) {
        let action = drawingController.end(coordinate: location)
        
        switch action {
        case .new(let control, let origin):
            document.undoManager?.registerUndo(withTarget: self, handler: { target in
                target.delete(control: control)
            })
            
            save()
        case .translate:
            // TODO: Add Undo
            save()
        case .click(let control):
            router.showSettings(for: control, controlSuperview: drawingController.view, delegate: self)
        case .none:
            break
        }
    }
    
    func showLabels() {
        drawingController.addLabels()
    }
    
    func hideLabels() {
        drawingController.removeLabels()
    }
}

extension EditorPresenter: SettingsDelegate {
    public func didUpdateValue() {
        save()
    }
    
    public func delete(control: A11yControl) {
        drawingController.delete(control: control)
        save()
    }
}
