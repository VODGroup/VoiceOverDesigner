import XCTest
import Document
import DocumentTestHelpers

final class DocumentVersionsTests: XCTestCase {

#if os(macOS)
    func test_canReadDocumentWithoutFrameFolder() throws {
        let document = try XCTUnwrap(Sample()
            .document(name: "BetaVersionFormat"))
        
        XCTAssertEqual(document.controls.count, 12)
        XCTAssertNotNil(document.image)
        XCTAssertEqual(document.frameInfo.imageScale, 1)
    }
    
    func test_canReadFrameFileFormat() throws {
        let document = try XCTUnwrap(Sample()
            .document(name: "ReleaseVersionFormat"))
        
        XCTAssertEqual(document.controls.count, 12)
        XCTAssertNotNil(document.image)
        XCTAssertEqual(document.frameInfo.imageScale, 3)
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
