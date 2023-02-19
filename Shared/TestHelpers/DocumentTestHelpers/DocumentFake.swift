import XCTest
import Combine
import Document

public class DocumentFake: VODesignDocumentProtocol {
    
    public init() {}
    
    // MARK: - Data
    public var controls: [any AccessibilityView] = []
    public var image: Image? = nil
    public var imageSize: CGSize = .zero
    public var frameInfo: FrameInfo = .default
    public var documentWrapper = FileWrapper(directoryWithFileWrappers: [:])
    public var previewSource: PreviewSourceProtocol?
    
    // MARK: -
    public var undo: UndoManager? = UndoManager()
}
