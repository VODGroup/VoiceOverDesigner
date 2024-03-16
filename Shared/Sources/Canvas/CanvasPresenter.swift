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
import QuartzCore

public class CanvasPresenter: DocumentPresenter {
    
    public weak var uiContent: DrawingView?
    var drawingController: DrawingController!

    public func didLoad(
        uiContent: DrawingView,
        initialScale: CGFloat,
        previewSource: PreviewSourceProtocol
    ) {
        self.uiContent = uiContent
        self.scale = initialScale
        self.drawingController = DrawingController(view: uiContent)
        self.document.previewSource = previewSource
        
        redraw(artboard: document.artboard)
    }
    
    private var scale: CGFloat = 1
    
    private var cancellables = Set<AnyCancellable>()
    
    public func subscribeOnControlChanges() {
        artboardPublisher
            .sink(receiveValue: redraw(artboard:))
            .store(in: &cancellables)
        
        selectedPublisher
            .sink(receiveValue: updateSelectedControl)
            .store(in: &cancellables)
    }
    
    public func stopObserving() {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
    private func redraw(artboard: Artboard) {
        drawingController.draw(
            artboard: artboard,
            scale: scale)
        updateSelectedControl(selectedPublisher.value)
    }
    
    // MARK: Mouse
    public func mouseDown(on location: CGPoint) {
        uiContent?.hud.hideHUD()

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
    public func mouseUp(on location: CGPoint) -> ArtboardElementLayer? {
        uiContent?.hud.showHUD()
        
        let action = drawingController.end(coordinate: location)
        
        let control = finish(action)
        return control
    }
    
    private func finish(_ action: DraggingAction?) -> ArtboardElementLayer? {
        if let action {
            print("Finish action \(action)")
        } else {
            print("Cancel action")
        }
        
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
            publishArtboardChanges()
            select(translate.control.model)
            
        case let resize as ResizeAction:
            registerUndo(for: resize)
            publishArtboardChanges()
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
            let selectedFrame = uiContent?.frames.first { frame in
                frame.frame == selectedDescription!.frame
            }
            selectedControl = selectedFrame
            
        case .element, .container:
            let selectedControl = uiContent?.drawnControls.first(where: { control in
                control.model?.frame == selectedDescription!.frame
            })
            
            self.selectedControl = selectedControl
        case .none:
            selectedControl = nil
        }
    }
    
    public private(set) var selectedControl: ArtboardElementLayer? {
        didSet {
            let model = selectedControl?.model
            
            uiContent?.hud.selectedControlFrame = model?.frame
            uiContent?.hud.tintColor = model?.color
                .cgColor.copy(alpha: 1) ?? Color.red.cgColor
        }
    }
    
    public var pointerPublisher: AnyPublisher<DrawingController.Pointer?, Never> {
        drawingController.pointerPublisher
    }
    
    private func control(for model: any ArtboardElement) -> A11yControlLayer? {
        uiContent?.drawnControls.first { control in
            control.model === model
        }
    }

    // MARK: - View actions
    public func cancelOperation() {
        drawingController.cancelOperation()
    }
    
    // MARK: Image
    public func add(image: Image, name: String) -> Frame {
        add(image: image, name: name, origin: document.artboard.suggestOrigin())
    }
    
    public override func remove(_ model: any ArtboardElement) {
        // Remove from layers
        // TODO: Unify layer creation
        if let frame = model as? Frame {
            let frameLayer = drawingController.cachedFrameLayer(for: frame)
            frameLayer?.removeFromSuperlayer()
        } else {
            // Element or container
            let layer = drawingController.cachedLayer(for: model)
            layer?.removeFromSuperlayer()
        }
        
        // Remove from model
        super.remove(model)
    }
    
    open override func wrapInContainer(
        _ elements: [any ArtboardElement]
    ) -> A11yContainer? {
        ///  Remove cached layers to allow reposition hierachy
        let elementsLayers = elements
            .compactMap(drawingController.cachedLayer(for:))
        remove(layers: elementsLayers)
        
        let container = super.wrapInContainer(elements)
        
        if let container {
            document.undoManager?.registerUndo(withTarget: self, handler: { presenter in
                if let layer = presenter.uiContent?.layer(for: container) {
                    presenter.uiContent?.delete(control: layer)
                }
            })
        }
        
        return container
    }
    
    private func remove(layers: [CALayer]) {
        for sublayer in layers
        {
            sublayer.removeFromSuperlayer()
        }
    }
    
#if canImport(XCTest)
    public override func replace(elements: [A11yDescription]) {
        remove(layers: drawingController.view.sublayers)
        
        super.replace(elements: elements)
    }
#endif
}

// MARK: - Undo
extension CanvasPresenter {
    func registerUndo(for action: Undoable) {
        document.undo?.registerUndo(withTarget: self, handler: { target in
            action.undo()
            target.publishArtboardChanges()
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
