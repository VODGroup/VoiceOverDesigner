import XCTest
import Combine
import Document

public class DocumentFake: VODesignDocumentProtocol {
    public init() {}
    
    // MARK: - Data
    public var controls: [any AccessibilityView] = []
    public var image: Image? = nil
    
    // MARK: -
    public var undo: UndoManager? = UndoManager()
}
