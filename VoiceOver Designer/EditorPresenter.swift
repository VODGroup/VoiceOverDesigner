//
//  EditorPresenter.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import Document
import AppKit

class EditorPresenter {
    
    var document: VODesignDocument!// (fileName: "Test")
    var drawingService: DrawingService!
    var router: Router!
    
    func didLoad(ui: NSView, controller: NSViewController) {
        drawingService = DrawingService(view: ui)
        router = Router(rootController: controller)
        
        loadAndDraw()
    }
    
    func loadAndDraw() {
        do {
//            document.read()
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
