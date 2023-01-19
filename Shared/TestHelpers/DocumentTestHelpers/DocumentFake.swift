import XCTest
import Combine
import Document

public class DocumentFake: VODesignDocumentProtocol {
    
    public init() {}
    
    // MARK: - Data
    public var controls: [any AccessibilityView] = []
    public var image: Image? = nil
    public var imageSize: CGSize = .zero
    
    // MARK: -
    public var undo: UndoManager? = UndoManager()
}
