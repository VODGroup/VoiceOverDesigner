import XCTest
import Document
import DocumentTestHelpers

final class DocumentVersionsTests: XCTestCase {

#if os(macOS)
    func test_canReadDocumentWithoutFrameFolder() throws {
        let fileName = "BetaVersionFormat"
        let document = try XCTUnwrap(Sample().document(name: fileName))
        
        try document.read()
        
        XCTAssertEqual(document.controls.count, 12)
        XCTAssertNotNil(document.image)
        XCTAssertNotNil(document.frameInfo)
    }

#elseif os(iOS)
    
    func test_canReadDocumentWithoutFrameFolder() async throws {
        let fileName = "BetaVersionFormat"
        let document = try XCTUnwrap(Sample().document(name: fileName))
        
        await document.read()

        await MainActor.run(body: {
            XCTAssertEqual(document.controls.count, 12)
            XCTAssertNotNil(document.image)
            XCTAssertNotNil(document.frameInfo)
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
