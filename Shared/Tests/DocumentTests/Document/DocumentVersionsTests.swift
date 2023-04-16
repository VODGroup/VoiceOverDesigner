import XCTest
@testable import Document
import DocumentTestHelpers

final class DocumentVersionsTests: XCTestCase {

#if os(macOS)
    func test_canReadDocumentWithoutFrameFolder() throws {
        let document = try XCTUnwrap(Sample()
            .document(name: "BetaVersionFormat"))
        
        XCTAssertEqual(document.elements.count, 12)
        XCTAssertNotNil(document.image)
        XCTAssertEqual(document.frameInfo.imageScale, 1, "Old format doesn't know about scale")
    }

    func test_whenReadOldFormat_shouldSaveAtNewFormat() throws {
        try copySampleFileAndRestoreAtTearDown(name: "BetaVersionFormat")
        
        let document = try XCTUnwrap(Sample().document(name: "BetaVersionFormat"))
        XCTAssertTrue(document.isBetaStructure, "Read as old file structure")
        
        saveDocumentAndRemoveAtTearDown(document: document, name: "TestDocument")
        XCTAssertFalse(document.isBetaStructure, "Update file structure after saving")
    }
    
    func test_canReadFrameFileFormat() throws {
        let document = try XCTUnwrap(Sample()
            .document(name: "FrameVersionFormat"))
        
        XCTAssertFalse(document.isBetaStructure)
        
        XCTAssertEqual(document.elements.count, 12)
        XCTAssertNotNil(document.image)
        XCTAssertEqual(document.frameInfo.imageScale, 3)
    }
    
    // MARK: - Restoration DSL
    private let fileManager = FileManager.default
    private func copySampleFileAndRestoreAtTearDown(name: String) throws {
        let path = try XCTUnwrap(Sample().documentPath(name: name))
        let bundlePath = path.deletingLastPathComponent()
        let restorationPath = bundlePath.appendingPathComponent("\(name)-Restore.vodesign")
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
