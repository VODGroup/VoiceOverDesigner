//
//  EditorPresenter.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import Document
import AppKit
import Combine

public class DocumentPresenter {
    
    public init(document: VODesignDocumentProtocol) {
        self.document = document
    }
    
    public private(set) var document: VODesignDocumentProtocol
    
    var drawingController: DrawingController!
    var ui: DrawingView!
    
    public func save() {
        let descriptions = ui.drawnControls.compactMap { control in
            control.a11yDescription
        }
        
        document.controls = descriptions
    }
    
    public var selectedPublisher = OptionalDescriptionSubject(nil)
    
    func update(image: Image) {
        document.image = image
    }
    
    func update(controls: [A11yDescription]) {
        document.controls = controls
    }
}

public class EditorPresenter: DocumentPresenter {
    
    func didLoad(ui: DrawingView) {
        self.ui = ui
        self.drawingController = DrawingController(view: ui)
        
        draw(controls: document.controls)
        redrawOnControlChanges()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func redrawOnControlChanges() {
        document
            .controlsPublisher
            .sink(receiveValue: redraw(controls:))
            .store(in: &cancellables)
        
        selectedPublisher
            .sink(receiveValue: updateSelectedControl)
            .store(in: &cancellables)
    }
    
    private func redraw(controls: [A11yDescription]) {
        drawingController.view.removeAll()
        draw(controls: controls)
        updateSelectedControl(selectedPublisher.value)
    }
    
    func draw(controls: [A11yDescription]) {
        drawingController.drawControls(controls)
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
                target.delete(model: new.control.a11yDescription!)
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
    
    // MARK: - Selection
    private func updateSelectedControl(_ selectedDescription: A11yDescription?) {
        guard let selected = selectedDescription else {
            selectedControl = nil
            return
        }
        
        let selectedControl = ui.drawnControls.first(where: { control in
            control.a11yDescription?.frame == selected.frame
        })
            
        self.selectedControl = selectedControl
    }
    
    public private(set) var selectedControl: A11yControl? {
        didSet {
            oldValue?.isSelected = false
            
            selectedControl?.isSelected = true
        }
    }
    
    func select(control: A11yControl) {
        selectedPublisher.send(control.a11yDescription)
    }
    
    func deselect() {
        selectedPublisher.send(nil)
    }
    
    // MARK: - Labels
    func showLabels() {
        ui.addLabels()
    }
    
    func hideLabels() {
        ui.removeLabels()
    }
    
    // MARK: - Deletion
    public func delete(model: A11yDescription) {
        guard let control = control(for: model) else {
            return
        }
        
        ui.delete(control: control)
        
        save()
    }
    
    private func control(for model: A11yDescription) -> A11yControl? {
        ui.drawnControls.first { control in
            control.a11yDescription?.frame == model.frame
        }
    }
}
