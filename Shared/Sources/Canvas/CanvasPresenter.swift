//
//  CanvasPresenter.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import Document
import CoreText
import Combine
import TextRecognition

public class CanvasPresenter: DocumentPresenter {
    
    public func didLoad(
        ui: DrawingView,
        initialScale: CGFloat
    ) {
        self.ui = ui
        self.scale = initialScale
        self.drawingController = DrawingController(view: ui)
        
        draw(controls: document.controls)
        
        redrawOnControlChanges()
    }
    
    private var scale: CGFloat = 1
    
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
    
    private func redraw(controls: [any AccessibilityView]) {
        drawingController.view.removeAll()
        draw(controls: controls)
        updateSelectedControl(selectedPublisher.value)
    }
    
    public func redraw(control: any AccessibilityView) {
        drawingController.view.remove(control)
        drawingController.draw(control, scale: scale)
    }
    
    public func draw(controls: [any AccessibilityView]) {
        drawingController.drawControls(controls, scale: scale)
    }
    
    // MARK: Mouse
    public func mouseDown(on location: CGPoint) {
        guard document.image != nil else { return }
        drawingController.mouseDown(on: location, selectedControl: selectedControl)
    }
    
    public func mouseDragged(on location: CGPoint) {
        drawingController.drag(to: location)
    }
    
    
    public func mouseMoved(on location: CGPoint) {
        guard document.image != nil else { return }
        drawingController.mouseMoved(on: location, selectedControl: selectedControl)
    }
   
    @discardableResult
    public func mouseUp(on location: CGPoint) -> A11yControlLayer? {
        let action = drawingController.end(coordinate: location)
        

        let control = finish(action)
        return control
    }
    
    private func finish(_ action: DraggingAction?) -> A11yControlLayer? {
        switch action {
        case let new as NewControlAction:
            add(new.control.model!)
            select(control: new.control)
            return new.control
            
        case let translate as TranslateAction:
            document.undo?.registerUndo(withTarget: self, handler: { target in
                translate.undo()
                target.publishControlChanges()
            })
            publishControlChanges()
            return translate.control
            
        case let click as ClickAction:
            select(control: click.control)
            return click.control
        case let copy as CopyAction:
            add(copy.control.model!)
            publishControlChanges()
            return copy.control
        case let resize as ResizeAction:
            document.undo?.registerUndo(withTarget: self, handler: { target in
                resize.control.frame = resize.initialFrame
            })
            return resize.control
            // TODO: Register resize as file change
        case .none:
            deselect()
            return nil
            
        default:
            assert(false, "Handle new type here")
            return nil
        }
        
        // TODO: Extract control from action
    }
    
    // MARK: - Selection
    private func updateSelectedControl(_ selectedDescription: (any AccessibilityView)?) {
        guard let selected = selectedDescription else {
            selectedControl = nil
            return
        }
        
        let selectedControl = ui.drawnControls.first(where: { control in
            control.model?.frame == selected.frame
        })
            
        self.selectedControl = selectedControl
    }
    
    public private(set) var selectedControl: A11yControlLayer? {
        didSet {
            oldValue?.isSelected = false
            
            selectedControl?.isSelected = true
        }
    }
    
    public func select(control: A11yControlLayer) {
        selectedPublisher.send(control.model)
    }
    
    public func deselect() {
        selectedPublisher.send(nil)
    }
    
    // MARK: - Labels
    public func showLabels() {
        ui.addLabels()
    }
    
    public func hideLabels() {
        ui.removeLabels()
    }
    
    public var pointerPublisher: AnyPublisher<DrawingController.Pointer?, Never> {
        drawingController.pointerPublisher
    }
    
    // MARK: - Deletion
    override public func remove(_ model: any AccessibilityView) {
        guard let control = control(for: model) else {
            return
        }
        
        // TODO: Delete control from document.elements
        ui.delete(control: control)
        
        super.remove(model)
    }
    
    private func control(for model: any AccessibilityView) -> A11yControlLayer? {
        ui.drawnControls.first { control in
            control.model === model
        }
    }
}
