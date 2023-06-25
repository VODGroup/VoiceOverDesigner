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
import Foundation

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
        
        drawingController.draw(
            artboard: document.artboard,
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
        artboardPublisher
            .sink(receiveValue: redraw(artboard:))
            .store(in: &cancellables)
        
        selectedPublisher
            .sink(receiveValue: updateSelectedControl)
            .store(in: &cancellables)
    }
    
    private func redraw(artboard: Artboard) {
        drawingController.view.removeAll()
        drawingController.draw(
            artboard: artboard,
            scale: scale)
        updateSelectedControl(selectedPublisher.value)
    }
    
    public func redraw(control: any ArtboardElement) {
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
            select(click.control.model)
            
        case let new as NewControlAction:
            append(control: new.control.model!)
            select(new.control.model)
            
        case let copy as CopyAction:
            append(control: copy.control.model!)
            select(copy.control.model)
            
        case let translate as TranslateAction:
            registerUndo(for: translate)
            publishControlChanges()
            select(translate.control.model)
            
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
    private func updateSelectedControl(_ selectedDescription: (any ArtboardElement)?) {
        switch selectedDescription?.cast {
        case .frame:
            let selectedFrame = uiContent.frames.first { frame in
                frame.frame == selectedDescription!.frame
            }
            uiContent.hud.selectedControlFrame = selectedFrame?.frame
            uiContent.hud.tintColor = Color.red.cgColor
            
        case .element, .container:
            let selectedControl = uiContent.drawnControls.first(where: { control in
                control.model?.frame == selectedDescription!.frame
            })
            
            self.selectedControl = selectedControl
        case .none:
            selectedControl = nil
        }
    }
    
    public private(set) var selectedControl: A11yControlLayer? {
        didSet {
            uiContent.hud.selectedControlFrame = selectedControl?.frame
            uiContent.hud.tintColor = selectedControl?.model?.color.cgColor.copy(alpha: 1)
        }
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
    override public func remove(_ model: any ArtboardElement) {
        guard let control = control(for: model) else {
            return
        }
        
        // TODO: Register Delete Undo on child
        uiContent.delete(control: control)
        
        super.remove(model)
    }
    
    private func control(for model: any ArtboardElement) -> A11yControlLayer? {
        uiContent.drawnControls.first { control in
            control.model === model
        }
    }
    
    // MARK: Image
    public override func add(image: Image) {
        super.add(image: image)
        
        // TODO: Remove old?
        drawingController.draw(
            artboard: document.artboard,
            scale: scale)
        
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
