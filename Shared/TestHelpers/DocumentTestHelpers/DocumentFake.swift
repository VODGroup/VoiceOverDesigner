import XCTest
import Combine
import Document

public class DocumentFake: VODesignDocumentProtocol {
    public init() {}
    
    public var controlsPublisher: PassthroughSubject<[any AccessibilityView], Never> = .init()
    
    public var controls: [any AccessibilityView] = [] {
        didSet {
            undo?.registerUndo(withTarget: self, handler: { document in
                document.controls = oldValue
            })
            
            controlsPublisher.send(controls)
        }
    }
    
    public var undo: UndoManager? = UndoManager()
    public var image: Image? = nil
}
