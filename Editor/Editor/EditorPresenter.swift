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
    
    public var document: VODesignDocument!// (fileName: "Test")
    var drawingService: DrawingService!
    var router: RouterProtocol!
    
    func didLoad(ui: NSView, router: RouterProtocol) {
        drawingService = DrawingService(view: ui)
        self.router = router
        
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
             break
        case .translate(let control, let startLocation, let offset):
            if offset == .zero,
               let existedControl = drawingService.control(at: location) {
                router.showSettings(for: existedControl, delegate: self)
                
                // Reset frame
                existedControl.frame = control.frame.offsetBy(dx: -offset.x,
                                                              dy: -offset.y)
            } else {
                // Already translated
            }
            
        case .none:
            break
        }
        
        save()
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
