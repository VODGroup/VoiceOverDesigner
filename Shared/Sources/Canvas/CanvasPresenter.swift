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

public protocol CanvasScrollViewProtocol: AnyObject {
    func fitToWindow(animated: Bool)
}

public class CanvasPresenter: DocumentPresenter {
    
    public weak var uiContent: DrawingView!
    public weak var uiScroll: CanvasScrollViewProtocol!
    var drawingController: DrawingController!
    
    public func didLoad(
        uiContent: DrawingView,
        uiScroll: CanvasScrollViewProtocol,
        initialScale: CGFloat,
        previewSource: PreviewSourceProtocol
    ) {
        self.uiContent = uiContent
        self.uiScroll = uiScroll
        self.scale = initialScale
        self.drawingController = DrawingController(view: uiContent)
        self.document.previewSource = previewSource
        
        drawingController.drawFrames(
            document.artboard.frames,
            controlsWithoutFrame: document.artboard.controlsWithoutFrames,
            scale: scale)
        
        uiScroll.fitToWindow(animated: true)
        
        redrawOnControlChanges()
    }
    
    public func stopObserving() {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
    private var scale: CGFloat = 1
    
    private var cancellables = Set<AnyCancellable>()
    
    private func redrawOnControlChanges() {
        controlsPublisher
            .sink(receiveValue: redraw(controls:))
            .store(in: &cancellables)
        
        selectedPublisher
            .sink(receiveValue: updateSelectedControl)
            .store(in: &cancellables)
    }
    
    private func redraw(controls: [any AccessibilityView]) {
        drawingController.view.removeAll()
        drawingController.drawFrames(
            document.artboard.frames,
            controlsWithoutFrame: document.artboard.controlsWithoutFrames,
            scale: scale) // TODO: Draw passed frames
        updateSelectedControl(selectedPublisher.value)
    }
    
    public func redraw(control: any AccessibilityView) {
        drawingController.view.remove(control)
        drawingController.draw(element: control, scale: scale)
    }
    
    // MARK: Mouse
    public func mouseDown(on location: CGPoint) {
        uiContent.hud.hideHUD()
        drawingController.mouseDown(on: location,
                                    selectedControl: selectedControl)
    }
    
    public func mouseDragged(on location: CGPoint) {
        drawingController.drag(to: location)
    }
    
    
    public func mouseMoved(on location: CGPoint) {
        guard document.image != nil else { return }
        
        drawingController.mouseMoved(on: location,
                                     selectedControl: selectedControl)
    }
   
    @discardableResult
    public func mouseUp(on location: CGPoint) -> A11yControlLayer? {
        uiContent.hud.showHUD()
        
        let action = drawingController.end(coordinate: location)
        
        let control = finish(action)
        return control
    }
    
    private func finish(_ action: DraggingAction?) -> A11yControlLayer? {
        switch action {
        case let click as ClickAction:
            select(control: click.control)
            
        case let new as NewControlAction:
            add(new.control.model!)
            select(control: new.control)
            
        case let copy as CopyAction:
            add(copy.control.model!)
            select(control: copy.control)
            
        case let translate as TranslateAction:
            registerUndo(for: translate)
            publishControlChanges()
            select(control: translate.control)
            
        case let resize as ResizeAction:
            registerUndo(for: resize)
            publishControlChanges()
            // Should be selected already
            
        case .none:
            deselect()
            
        default:
            assert(false, "Handle new type here")
        }
        
        return action?.control
    }
    
    // MARK: - Selection
    private func updateSelectedControl(_ selectedDescription: (any AccessibilityView)?) {
        guard let selected = selectedDescription else {
            selectedControl = nil
            return
        }
        
        let selectedControl = uiContent.drawnControls.first(where: { control in
            control.model?.frame == selected.frame
        })
            
        self.selectedControl = selectedControl
    }
    
    public private(set) var selectedControl: A11yControlLayer? {
        didSet {
            uiContent.hud.selectedControlFrame = selectedControl?.frame
            uiContent.hud.tintColor = selectedControl?.model?.color.cgColor.copy(alpha: 1)
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
        uiContent.addLabels()
    }
    
    public func hideLabels() {
        uiContent.removeLabels()
    }
    
    public var pointerPublisher: AnyPublisher<DrawingController.Pointer?, Never> {
        drawingController.pointerPublisher
    }
    
    // MARK: - Deletion
    override public func remove(_ model: any AccessibilityView) {
        guard let control = control(for: model) else {
            return
        }
        
        // TODO: Register Delete Undo on child
        uiContent.delete(control: control)
        
        super.remove(model)
    }
    
    private func control(for model: any AccessibilityView) -> A11yControlLayer? {
        uiContent.drawnControls.first { control in
            control.model === model
        }
    }
    
    // MARK: Image
    public func add(image: Image) {
        update(image: image)
        // TODO: Check that image is drawn
//        drawFramesOnUI()
        publishControlChanges()
    }
}

// MARK: - Undo
extension CanvasPresenter {
    func registerUndo(for action: Undoable) {
        document.undo?.registerUndo(withTarget: self, handler: { target in
            action.undo()
            target.publishControlChanges()
        })
    }
}

protocol Undoable {
    func undo()
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
