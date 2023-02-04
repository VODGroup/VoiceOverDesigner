import Document
import XCTest
import DocumentTestHelpers

final class ThumbnailDocumentVersionsTests: XCTestCase {
    func test_canReadBetaVersionFormat() async throws {
        let thumbnail = try await thumbnail(for: "BetaVersionFormat")
        XCTAssertNotNil(thumbnail)
    }
    
    func test_canReadReleaseVersionFormat() async throws {
        let thumbnail = try await thumbnail(for: "FrameVersionFormat")
        XCTAssertNotNil(thumbnail)
    }
    
    func test_canReadFrameVersionFormatWithHeicPreview() async throws {
        let thumbnail = try await thumbnail(for: "FrameVersionFormatWithHeicPreview")
        XCTAssertNotNil(thumbnail)
    }
    
    // TODO: Invalidate png
}

func thumbnail(for documentName: String,
               file: StaticString = #file,
               line: UInt = #line
) async throws -> Image? {
    let documentPath = try XCTUnwrap(
        Sample().documentPath(name: documentName),
        file: file, line: line)
    
    let thumbnailDocument = ThumbnailDocument(documentURL: documentPath)
    let thumbnail = await thumbnailDocument.thumbnail(size: CGSize(width: 100,
                                                             height: 100),
                                                scale: 1)
    return thumbnail
}
