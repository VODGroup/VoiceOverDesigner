import XCTest
@testable import Canvas
import Document
import DocumentTestHelpers

class ArtboardAddImageTests: CanvasAfterDidLoadTests {
    
    func test_startFromEmptyArtboard() {
        XCTAssertTrue(document.artboard.isEmpty)
    }
    
    func test_whenAddImage_shouldAddFrameToDocument() {
        sut.add(image: Sample().image3x())
        
        XCTAssertNoThrow(try document.firstFrame())
    }
    
    func test_whenAddImage_shouldAddFrameToCanvas() {
        sut.add(image: Sample().image3x())
        
        XCTAssertEqual(drawnFrames.count, 1)
    }
    
    func test_whenAddImage_shouldSelectFrame() {
        sut.add(image: Sample().image3x())
        
        XCTAssertNotNil(sut.selectedControl)
    }
    
    func test_whenAddImageAndUndo_shouldRemoveFrameFromDocument() throws {
        sut.add(image: Sample().image3x())
        
        sut.undo()
        
        XCTAssertTrue(document.artboard.isEmpty)
    }
    
    func test_whenAddImageAndUndo_shouldRemoveFrameFromCanvas() throws {
        sut.add(image: Sample().image3x())
        
        sut.undo()
        
        XCTAssertTrue(drawnFrames.isEmpty)
    }
    
    /// There was a bug when several images expect migration,
    /// but the first was  `.relativeFile` and it calls `return` in migration loop instead of `break` operation,
    /// As a result all other `.cache` images skip migration
    func test_whenAddImageAndSave_shouldMigrateBothImageFromCache() throws {
        sut.add(image: Sample().image3x())
        
        try save()
        
        sut.add(image: Sample().image3x())
        
        try save()
    }
    
    private func save() throws {
        try (sut.document as! VODesignDocument).save(name: testDocumentName, testCase: self)
    }
}
