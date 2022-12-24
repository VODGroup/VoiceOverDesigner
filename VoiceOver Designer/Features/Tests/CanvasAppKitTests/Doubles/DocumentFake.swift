import XCTest
@testable import Canvas
import Combine
import Document

class DocumentFake: VODesignDocumentProtocol {
    var controlsPublisher: PassthroughSubject<[any AccessibilityView], Never> = .init()
    
    var controls: [any AccessibilityView] = [] {
        didSet {
            controlsPublisher.send(controls)
        }
    }
    
    var undo: UndoManager? = UndoManager()
    var image: Image? = nil
}
