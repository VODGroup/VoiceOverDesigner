import XCTest
@testable import Canvas
import Combine
import Document

class DocumentFake: VODesignDocumentProtocol {
    var controlsPublisher: PassthroughSubject<[A11yDescription], Never> = .init()
    
    var controls: [A11yDescription] = [] {
        didSet {
            controlsPublisher.send(controls)
        }
    }
    
    var undoManager: UndoManager? = UndoManager()
    var image: Image? = nil
}
