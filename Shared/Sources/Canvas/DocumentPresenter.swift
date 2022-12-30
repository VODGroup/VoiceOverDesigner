import Foundation
import Document

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
        let removedIndex = document.controls.remove(model)
        
        if let _ = removedIndex {
            return
        }
        
        for container in document.controls.extractContainers() {
            let removedIndex = container.remove(model as! A11yDescription)
            
            if let _ = removedIndex {
                return
            }
        }
        
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
