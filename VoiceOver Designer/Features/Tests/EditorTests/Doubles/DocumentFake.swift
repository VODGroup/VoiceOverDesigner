import XCTest
@testable import Editor
import Combine
import Document

class DocumentFake: VODesignDocumentProtocol {
    var controlsPublisher: PassthroughSubject<[A11yDescription], Never> = .init()
    
    var controls: [A11yDescription] = []
    var undoManager: UndoManager? = nil
    var image: Image? = nil
}
