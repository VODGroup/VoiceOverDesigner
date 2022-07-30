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
    var ui: DrawingView!
    var router: EditorRouterProtocol!
    
    func didLoad(ui: DrawingView, router: EditorRouterProtocol) {
        self.ui = ui
        self.drawingController = DrawingController(view: ui)
        self.router = router
        
        draw()
    }
    
    func draw() {
        document.controls.forEach { control in
            drawingController.drawControl(from: control)
        }
    }
    
    func save() {
        let descriptions = ui.drawnControls.compactMap { control in
            control.a11yDescription
        }
        
        document.controls = descriptions
    }
    
    // MARK: Mouse
    func mouseDown(on location: CGPoint) {
        drawingController.mouseDown(on: location)
    }
    
    func mouseDragged(on location: CGPoint) {
        drawingController.drag(to: location)
    }
    
    func mouseUp(on location: CGPoint) {
        let action = drawingController.end(coordinate: location)
        
        switch action {
        case let new as NewControlAction:
            document.undoManager?.registerUndo(withTarget: self, handler: { target in
                target.delete(control: new.control)
            })
            
            save()
            
        case let translate as TranslateAction:
            document.undoManager?.registerUndo(withTarget: self, handler: { target in
                translate.undo()
            })
            save()
        case let click as ClickAction:
            selectedControl = click.control
            router.showSettings(for: click.control, controlSuperview: drawingController.view, delegate: self)
            
        case .none:
            selectedControl = nil
            router.hideSettings()
        default:
            assert(false, "Handle new type here")
            break
        }
    }
    
    var selectedControl: A11yControl? {
        didSet {
            oldValue?.isSelected = false
            
            selectedControl?.isSelected = true
        }
    }
    
    func showLabels() {
        ui.addLabels()
    }
    
    func hideLabels() {
        ui.removeLabels()
    }
}

extension EditorPresenter: SettingsDelegate {
    public func didUpdateValue() {
        save()
    }
    
    public func delete(control: A11yControl) {
        ui.delete(control: control)
        save()
    }
}
