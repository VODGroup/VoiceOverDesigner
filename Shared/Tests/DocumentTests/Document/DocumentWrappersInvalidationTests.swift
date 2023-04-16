import XCTest
@testable import Document
import DocumentTestHelpers

class DocumentWrappersInvalidationTests: XCTestCase {
    
    var document: VODesignDocument!
    var path: URL!

    // MARK: - DSL
    private var framePath: URL {
        path.appendingPathComponent(defaultFrameName)
    }
    
    private func pathInFrame(_ fileName: String) -> URL {
        path
            .appendingPathComponent(defaultFrameName)
            .appendingPathComponent(fileName)
    }
    
    var firstFrame: FileWrapper? {
        document.frameWrappers[0]
    }
    
    private func assertMatchContentInFrame(
        _ fileName: String,
        file: StaticString = #file, line: UInt = #line
    ) throws {
        let wrapper = try XCTUnwrap(firstFrame?[fileName], file: file, line: line)
        let path = pathInFrame(fileName)
        XCTAssertTrue(wrapper.matchesContents(of: path), file: file, line: line)
    }
    
    private func assertNotMatchContentInFrame(
        _ fileName: String,
        file: StaticString = #file, line: UInt = #line
    ) throws {
        let wrapper = try XCTUnwrap(firstFrame?[fileName], file: file, line: line)
        let path = pathInFrame(fileName)
        XCTAssertFalse(wrapper.matchesContents(of: path), file: file, line: line)
    }
    
    // MARK: - Tests
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        document = try XCTUnwrap(Sample()
            .document(name: "FrameVersionFormat"))
        
        path = try XCTUnwrap(Sample().documentPath(name: "FrameVersionFormat"))
    }
    
    func test_matchesContentAfterReading() {
        XCTAssertTrue(document.documentWrapper.matchesContents(of: path))
    }
    
    func test_whenUpdateImage_shouldInvalidateImage() throws {
        XCTAssertNotNil(firstFrame?[FileName.screen], "image is here")
        
        document.addFrame(with: Image())
        
        XCTAssertNil(firstFrame?[FileName.screen], "image is invalidated")
    }
    
    func test_whenUpdateImage_shouldInvalidateScale() throws {
        try assertMatchContentInFrame(FileName.info)
        
        document.addFrame(with: Image())
        
        XCTAssertNil(firstFrame?[FileName.info], "info is invalidated")
    }
    
    func test_whenUpdateImage_shouldInvalidateQuickLookFile() throws {
        document.addFrame(with: Image())
        
        XCTAssertNil(firstFrame?[FolderName.quickLook], "quickLook is invalidated")
    }
}

extension FileWrapper {
    subscript(_ name: String) -> FileWrapper? {
        return fileWrappers?[name]
    }
}
