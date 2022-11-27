import XCTest
@testable import Editor
import Combine
import Document

class DocumentFake: VODesignDocumentProtocol {
    var controlsPublisher: PassthroughSubject<[any AccessibilityView], Never> = .init()
    
    var controls: [any AccessibilityView] = [] {
        didSet {
            controlsPublisher.send(controls)
        }
    }
    
    var undoManager: UndoManager? = UndoManager()
    var image: Image? = nil
}
