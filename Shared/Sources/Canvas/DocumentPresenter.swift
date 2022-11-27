import Foundation
import Document

open class DocumentPresenter {
    
    public init(document: VODesignDocumentProtocol) {
        self.document = document
    }
    
    public private(set) var document: VODesignDocumentProtocol
    
    var drawingController: DrawingController!
    public weak var ui: DrawingView!
    
    public func save() {
        let descriptions = ui.drawnControls.compactMap { control in
            control.a11yDescription
        }
        
        document.controls = descriptions
    }
    
    public let selectedPublisher = OptionalDescriptionSubject(nil)
    public let recognitionPublisher = TextRecognitionSubject(nil)
    
    public func update(image: Image) {
        document.image = image
    }
    
    func update(controls: [A11yDescription]) {
        document.controls = controls
    }
    
    func publish(textRecognition: RecognitionResult) {
        recognitionPublisher.send(textRecognition)
    }
}
