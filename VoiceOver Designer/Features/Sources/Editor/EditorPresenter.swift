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
    
    public let selectedPublisher = OptionalDescriptionSubject(nil)
    public let recognitionPublisher = TextRecognitionSubject(nil)
    
    func update(image: Image) {
        document.image = image
    }
    
    func update(controls: [A11yDescription]) {
        document.controls = controls
    }
    
    func publish(textRecognition: RecognitionResult) {
        recognitionPublisher.send(textRecognition)
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
    
    func mouseUp(on location: CGPoint) -> A11yControl? {
        let action = drawingController.end(coordinate: location)
        
        switch action {
        case let new as NewControlAction:
            document.undoManager?.registerUndo(withTarget: self, handler: { target in
                target.delete(model: new.control.a11yDescription!)
            })
            
            save()
            select(control: new.control)
            return new.control
            
        case let translate as TranslateAction:
            document.undoManager?.registerUndo(withTarget: self, handler: { target in
                translate.undo()
            })
            save()
            return translate.control
            
        case let click as ClickAction:
            select(control: click.control)
            return click.control
        case let copy as CopyAction:
            document.undoManager?.registerUndo(withTarget: self, handler: { target in
                target.delete(model: copy.control.a11yDescription!)
            })
            save()
            return copy.control
        case let resize as ResizeAction:
            document.undoManager?.registerUndo(withTarget: self, handler: { target in
                resize.control.frame = resize.initialFrame
            })
            return resize.control
        case .none:
            deselect()
            return nil
            
        default:
            assert(false, "Handle new type here")
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
    public func showLabels() {
        ui.addLabels()
    }
    
    public func hideLabels() {
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
    
    // MARK: Text recognition
    
    private let textRecognition = TextRecognitionService()
    
    func recognizeText(image: CGImage, control: A11yControl) async {
        do {
            let recognitionResults = try await textRecognition.processImage(image: image)
            let results = RecognitionResult(control: control,
                                            text: recognitionResults)
            guard !results.text.isEmpty else { return }
            
            publish(textRecognition: results)
        } catch let error {
            print(error)
        }
    }
}
