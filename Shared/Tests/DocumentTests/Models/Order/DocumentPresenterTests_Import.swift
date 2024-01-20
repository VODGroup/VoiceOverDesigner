import XCTest
import Document
import DocumentTestHelpers
@testable import Artboard

final class DocumentPresenterTests_Import: XCTestCase {
    
    var sut: DocumentPresenter!
    var document: VODesignDocument!
    var document2: VODesignDocument!
    
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
    
    override func tearDownWithError() throws {
        try? VODesignDocument.removeTestDocument(name: "Test")
        document = nil
        sut = nil
        super.tearDown()
    }
    
    lazy var frameSpacing: CGFloat = 1170
    lazy var frame1Size = CGSize(width: 1170, height: 3407)
    lazy var frame1 = CGRect(
        origin: CGPoint(x: 2340,
                        y: 0),
        size: frame1Size)
    
    lazy var frame2Size = CGSize(width: 1170, height: 3372)
    lazy var frame2 = CGRect(origin: .zero,
                        size: frame2Size)
    
    func test_defaultFramesCount() {
        XCTAssertEqual(document.artboard.frames.count, 2)
        XCTAssertEqual(document.artboard.proposedOffsetBetweenFrames, frameSpacing)
        XCTAssertEqual(frame(at: 0).frame, frame1)
        XCTAssertEqual(frame(at: 1).frame, frame2)
    }
    
    func test_whenImportArtboard_shouldAddFrames() {
        sut.importArtboard(document2)
        XCTAssertEqual(document.artboard.frames.count, 4)
    }
    
    func test_whenImportArtboard_shouldOffsetFrames() {
        sut.importArtboard(document2)
        
        XCTAssertEqual(frame(at: 0).frame, frame1, "Stay on place")
        XCTAssertEqual(frame(at: 1).frame, frame2, "Stay on place")
        
        let offsetForFrame1 = frame(at: 2).frame.xOffset(from: frame1)
        XCTAssertEqual(offsetForFrame1, 1170, "Moved")
        
        let offsetForFrame2 = frame(at: 3).frame.xOffset(from: frame2)
        XCTAssertEqual(offsetForFrame2, 5850.0, "Moved")
    }
    
    func test_whenImportArtboard_shouldOffsetElements() throws {
        sut.importArtboard(document2)
        
        let element1InFrame1 = try XCTUnwrap(frame(at: 0).elements.first)
        let element1InFrame3 = try XCTUnwrap(frame(at: 3).elements.first)
        
        XCTAssertEqual(element1InFrame1.label, element1InFrame3.label,
                       "should check equal elements")
        XCTAssertEqual(
            element1InFrame3.frame.xOffset(from: element1InFrame1.frame),
            3747, "Moved")
    }
    
    // TODO: Artboard contains 2 frames and it makes calculation harder
    
    // MARK: - DSL
    
    private func frame(at index: Int) -> Frame {
        document.artboard.frames[index]
    }
}

