import Foundation
import Document

/**
 Top level object that controls abstract VODesignDocumentProtocol
 
 Allowh to publishControlChanges after any changes on controls level to initiate UI update of any ViewController
 Also manages undo changes on controls level

 */
open class DocumentPresenter {
    
    public init(document: VODesignDocumentProtocol) {
        self.document = document
    }
    
    public private(set) var document: VODesignDocumentProtocol
    
    var drawingController: DrawingController!
    public weak var ui: DrawingView!
    
    public func publishControlChanges() {
        document.controlsPublisher.send(document.controls)
    }
    
    public let selectedPublisher = OptionalDescriptionSubject(nil)
    
    public func update(image: Image) {
        document.image = image
    }
    
    public func update(controls: [A11yDescription]) {
        document.controls = controls
    }
    
    public func append(control: any AccessibilityView) {
        document.controls.append(control)
    }
    
    public func add(_ model: any AccessibilityView) {
        append(control: model)
        
        publishControlChanges()
    }
    
    public func remove(_ model: any AccessibilityView) {
        switch model.cast {
        case .element(let element):
            if let topLevelIndex = document.controls.delete(element) {
                document.undo?.registerUndo(withTarget: self, handler: { presenter in
                    presenter.insert(model: element, at: topLevelIndex)
                })
            } else {
                guard let container = document.controls.container(for: element),
                      let containerIndex = container.elements.remove(element)
                else { return }
                
                document.undo?.registerUndo(withTarget: self, handler: { presenter in
                    presenter.insert(element, into: container, at: containerIndex)
                })
            }
            
        case .container(let container):
            document.delete(container)
        }
        
        publishControlChanges()
    }
    
    private func insert(
        _ model: A11yDescription,
        into container: A11yContainer,
        at instertionIndex: Int
    ) {
        container.elements.insert(model, at: instertionIndex)
        publishControlChanges()
    }
    
    private func insert(
        model: A11yDescription,
        at instertionIndex: Int
    ) {
        document.controls.insert(model, at: instertionIndex)
        publishControlChanges()
    }
    
    @discardableResult
    public func wrapInContainer(
        _ elements: [any AccessibilityView]
    ) -> A11yContainer? {
        document.controls.wrapInContainer(
            elements.extractElements(),
            label: "Container")
    }
}
