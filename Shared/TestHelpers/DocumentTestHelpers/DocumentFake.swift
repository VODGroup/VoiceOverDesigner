import XCTest
import Combine
@testable import Document

public class DocumentFake: AppleDocument, VODesignDocumentProtocol {
    
    public override init() {
        artboard.imageLoader = DummyImageLoader()
    }
    
    // MARK: - Data
    public var controls: [any ArtboardElement] = []
    public var image: Image? = nil
    public var imageSize: CGSize = .zero
    public var frameInfo: FrameInfo = .default
    public var frames: [Frame] = []
    public var artboard = Artboard()
    
    public var documentWrapper = FileWrapper(directoryWithFileWrappers: [:])
    public var imagesFolderWrapper: FileWrapper?
    public var previewSource: PreviewSourceProtocol?
    
    // MARK: -
    public var undo: UndoManager? = UndoManager()
}
