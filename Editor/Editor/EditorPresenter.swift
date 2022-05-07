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
    var drawingService: DrawingService!
    var router: RouterProtocol!
    
    func didLoad(ui: NSView, router: RouterProtocol) {
        drawingService = DrawingService(view: ui)
        self.router = router
        
        draw()
    }
    
    func draw() {
        document.controls.forEach(drawingService.drawControl(from:))
    }
    
    func save() {
        let descriptions = drawingService.drawnControls.compactMap { control in
            control.a11yDescription
        }
        
        document.controls = descriptions
    }
    
    // MARK: Mouse
    func mouseDown(on location: CGPoint) {
        if let existedControl = drawingService.control(at: location) {
            drawingService.startTranslating(control: existedControl,
                                            startLocation: location)
        } else {
            drawingService.startDrawing(coordinate: location)
        }
    }
    
    func mouseDragged(on location: CGPoint) {
        drawingService.drag(to: location)
    }
    
    func mouseUp(on location: CGPoint) {
        let action = drawingService.end(coordinate: location)
        
        switch action {
        case .new(let control, let origin):
            document.undoManager?.registerUndo(withTarget: self, handler: { target in
                target.delete(control: control)
            })
            
            save()
        case .translate(let control, let startLocation, let offset):
            save()
        case .click(let control):
            router.showSettings(for: control, delegate: self)
        case .none:
            break
        }
    }
}

extension EditorPresenter: SettingsDelegate {
    public func didUpdateValue() {
        save()
    }
    
    public func delete(control: A11yControl) {
        drawingService.delete(control: control)
        save()
    }
}
