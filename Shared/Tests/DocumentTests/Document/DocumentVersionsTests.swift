import XCTest
@testable import Document
import DocumentTestHelpers

final class DocumentVersionsTests: XCTestCase {

#if os(macOS)
    func test_betaDocument_whenReads_shouldMoveElementsToFirstFrame() throws {
        let document = try XCTUnwrap(Sample().document(name: "BetaVersionFormat"))
        
        let frame = try XCTUnwrap(document.artboard.frames.first)
        
        XCTAssertEqual(frame.elements.count, 12)
        XCTAssertNotNil(frame.image)
    }

    func test_whenReadOldFormat_shouldSaveAtNewFormat() throws {
        try copySampleFileAndRestoreAtTearDown(name: "BetaVersionFormat")
        
        let document = try XCTUnwrap(Sample().document(name: "BetaVersionFormat"))
        XCTAssertFalse(document.isBetaStructure, "Should migrate to new file structure right on read")
        
        saveDocumentAndRemoveAtTearDown(document: document, name: "TestDocument")
    }
    
    func test_canReadFrameFileFormat() throws {
        let document = try XCTUnwrap(Sample().document(name: "FrameVersionFormat"))
        XCTAssertFalse(document.isBetaStructure)
        
        let frame = try XCTUnwrap(document.artboard.frames.first)
        
        XCTAssertEqual(frame.elements.count, 12)
        XCTAssertNotNil(frame.image)
        XCTAssertEqual(frame.frame, CGRect(x: 0, y: 0, width: 390, height: 844), "should scale frame")
    }
    
    func test_artboardFormat() throws {
        let document = try XCTUnwrap(Sample().document(name: "ArtboardFormat"))
        
        let artboard = document.artboard
        XCTAssertEqual(artboard.frames.count, 2)
        XCTAssertEqual(artboard.controlsWithoutFrames.count, 0)
        
        let frame1 = try XCTUnwrap(artboard.frames.first)
        XCTAssertEqual(frame1.elements.count, 10)
        XCTAssertNotNil(frame1.image)
        XCTAssertEqual(frame1.frame, CGRect(x: 2340, y: 0, width: 1170, height: 3407), "should scale frame")
    }
    
    // MARK: - Restoration DSL
    private let fileManager = FileManager.default
    private func copySampleFileAndRestoreAtTearDown(name: String) throws {
        let path = try XCTUnwrap(Sample().documentPath(name: name))
        let bundlePath = path.deletingLastPathComponent()
        let restorationPath = bundlePath.appendingPathComponent("\(name)-Restore.vodesign")
        try? fileManager.removeItem(at: restorationPath)
        try fileManager.copyItem(at: path, to: restorationPath)
        addTeardownBlock {
            try _ = self.fileManager.replaceItemAt(path, withItemAt: restorationPath)
        }
    }
    
    private func saveDocumentAndRemoveAtTearDown(document: VODesignDocument, name: String) {
        document.save(testCase: self, fileName: name)
        addTeardownBlock {
            let testFilePath = Sample().resourcesPath().appendingPathComponent("\(name).vodesign")
            try? self.fileManager.removeItem(at: testFilePath)
        }
    }

#elseif os(iOS)
    
    func test_canReadDocumentWithoutFrameFolder() async throws {
        let fileName = "BetaVersionFormat"
        let document = try XCTUnwrap(Sample().document(name: fileName))
        
        await document.read()

        await MainActor.run(body: {
            XCTAssertEqual(document.elements.count, 12)
            XCTAssertNotNil(document.image)
            XCTAssertEqual(document.frameInfo.imageScale, 1, "Old format doesn't know about scale")
        })
    }
    
    func test_canReadFrameFileFolrmat() async throws {
        let fileName = "ReleaseVersionFormat"
        let document = try XCTUnwrap(Sample().document(name: fileName))
        
        await document.read()

        await MainActor.run(body: {
            XCTAssertEqual(document.elements.count, 12)
            XCTAssertNotNil(document.image)
            XCTAssertEqual(document.frameInfo.imageScale, 3)
        })
    }
#endif
}

#if os(iOS)
extension Document {
    func read() async {
        await withCheckedContinuation({ continuation in
            open(completionHandler: { _ in
                continuation.resume()
            })
        })
    }
}
#endif
