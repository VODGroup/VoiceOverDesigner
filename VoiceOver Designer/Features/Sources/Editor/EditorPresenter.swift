//
//  EditorPresenter.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import Document
import AppKit
import Combine

public class EditorPresenter {
    
    public var document: VODesignDocumentProtocol!
    var drawingController: DrawingController!
    var ui: DrawingView!
    weak var router: EditorRouterProtocol!
    weak var delegate: EditorDelegate!
    
    func didLoad(ui: DrawingView, router: EditorRouterProtocol, delegate: EditorDelegate) {
        self.ui = ui
        self.drawingController = DrawingController(view: ui)
        self.router = router
        self.delegate = delegate
        
        draw(controls: document.controls)
        redrawOnControlChanges()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func redrawOnControlChanges() {
        document
            .controlsPublisher
            .sink { controls in
                self.drawingController.view.removeAll()
                self.draw(controls: controls)
                self.selectPreviousSelected()
            }
            .store(in: &cancellables)
    }
    
    private func selectPreviousSelected() {
        if let selected = self.selectedControl?.a11yDescription {
            self.selectedControl = self.drawingController.view
                .drawnControls
                .first(where: { control in
                    selected.frame == control.frame // Can be same by description (empty, for e.g. but should select same in place
                })
        }
    }
    
    func draw(controls: [A11yDescription]) {
        drawingController.drawControls(controls)
    }
    
    public func save() {
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
            select(control: new.control)
            
        case let translate as TranslateAction:
            document.undoManager?.registerUndo(withTarget: self, handler: { target in
                translate.undo()
            })
            save()
        case let click as ClickAction:
            select(control: click.control)
            
        case .none:
            deselect()
        default:
            assert(false, "Handle new type here")
            break
        }
    }
    
    func select(control: A11yControl, tellToDelegate: Bool = true) {
        selectedControl = control
        router.showSettings(for: control, controlSuperview: drawingController.view)
        
        if tellToDelegate {
            delegate.didSelect(control: selectedControl?.a11yDescription)
        }
    }
    
    func deselect() {
        selectedControl = nil
        router.hideSettings()
    }
    
    private(set) var selectedControl: A11yControl? {
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

extension EditorPresenter {
    
    public func delete(control: A11yControl) {
        ui.delete(control: control)
        save()
    }
}
