import XCTest
import Document
import DocumentTestHelpers

final class DocumentPresenterTests_Import: XCTestCase {
    
    var sut: DocumentPresenter!
    var document: VODesignDocumentProtocol!
    var document2: VODesignDocumentProtocol!
    
    var element1: A11yDescription!
    var element2: A11yDescription!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        document = try Sample().document(name: FileSample.artboard, testCase: self)
        
        document2 = try Sample().document(
            name: FileSample.artboard,
            fileName: FileSample.artboard + "2",
            testCase: self)
        
        
        sut = DocumentPresenter(document: document)
    }
    
    lazy var frameOffset: CGFloat = 1170
    lazy var frame1Size = CGSize(width: 1170, height: 3407)
    lazy var frame1 = CGRect(
        origin: CGPoint(x: frame2Size.width + frameOffset, // 2340
                        y: 0),
        size: frame1Size)
    
    lazy var frame2Size = CGSize(width: 1170, height: 3372)
    lazy var frame2 = CGRect(origin: .zero,
                        size: frame2Size)
    
    func test_defaultFramesCount() {
        XCTAssertEqual(document.artboard.frames.count, 2)
        
        XCTAssertEqual(frame(at: 0).frame, frame1)
        XCTAssertEqual(frame(at: 1).frame, frame2)
    }
    
    func test_whenImportArtboard_shouldAddFrames() {
        sut.importArtboard(document2.artboard)
        XCTAssertEqual(document.artboard.frames.count, 4)
    }
    
    func test_whenImportArtboard_shouldOffsetFrames() {
        sut.importArtboard(document2.artboard)
        
        XCTAssertEqual(frame(at: 0).frame, frame1, "Stay on place")
        XCTAssertEqual(frame(at: 1).frame, frame2, "Stay on place")
        
        XCTAssertEqual(frame(at: 2).frame, frame1
            .offsetBy(dx: frameOffset, dy: 0), "Moved")
        XCTAssertEqual(frame(at: 3).frame, frame2
            .offsetBy(dx: frameOffset, dy: 0), "Moved")
    }
    
    func test_whenImportArtboard_shouldOffsetElements() {
        sut.importArtboard(document2.artboard)
        
        let element1InFrame1 = frame(at: 0).elements.first
        let element1InFrame3 = frame(at: 2).elements.first
        XCTAssertEqual(
            element1InFrame1?.frame.offsetBy(dx: frameOffset, dy: 0),
            element1InFrame3?.frame, "Moved")
    }
    
    // MARK: - DSL
    
    private func frame(at index: Int) -> Frame {
        document.artboard.frames[index]
    }
}
