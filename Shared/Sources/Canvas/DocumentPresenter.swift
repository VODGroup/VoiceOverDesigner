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
    
    func update(controls: [A11yDescription]) {
        document.controls = controls
    }
    
    func append(control: any AccessibilityView) {
        document.controls.append(control)
    }
    
    func remove(control: any AccessibilityView) {
        
        switch control.cast {
            
        case .element(let description):
            document.delete(description)
        case .container(let container):
            document.delete(container)
        }
        

    }
}
