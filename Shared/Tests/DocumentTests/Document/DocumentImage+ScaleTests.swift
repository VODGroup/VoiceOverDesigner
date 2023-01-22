import XCTest
import Document
import DocumentTestHelpers

final class DocumentImage_ScaleTests: XCTestCase {

    let scaledSize = CGSize(width: 390, height: 180)
    let rawSize = CGSize(width: 1170, height: 540)
    
    let imageName = "screenWith3xScale.png"
    let documentName = "TestFile1"
    
    override func tearDown() {
        super.tearDown()
        
        try? VODesignDocument.removeTestDocument(name: documentName)
    }
    
    func imageWith3xScale(file: StaticString = #file, line: UInt = #line) throws -> Image {
        let imageWith3xScale = try XCTUnwrap(Sample().image(name: imageName))
        
#if os(macOS)
        XCTAssertEqual(imageWith3xScale.size, scaledSize, file: file, line: line)
        XCTAssertEqual(imageWith3xScale.recommendedLayerContentsScale(1), 3, file: file, line: line)
        return imageWith3xScale
#elseif os(iOS)
        XCTAssertEqual(imageWith3xScale.size, rawSize, "imaga size doesn't know aboul scale", file: file, line: line)
        XCTAssertEqual(imageWith3xScale.scale, 1, file: file, line: line)
        return imageWith3xScale
#endif
    }
    
#if os(macOS)
    func test_APPKit_whenCreateFileFromImage_shouldSetImageSizeWithScale() throws {
        let document = VODesignDocument(image: try imageWith3xScale())
        
        XCTAssertEqual(document.imageSize, scaledSize)
        XCTAssertEqual(document.frameInfo.imageScale, 3)
    }
    
    func test_APPKit_whenUpdateImageExternaly_shouldSetImageSizeWithScale() throws {
        let document = VODesignDocument(fileName: documentName)
        document.updateImage(try imageWith3xScale())
        
        XCTAssertEqual(document.imageSize, scaledSize)
        XCTAssertEqual(document.frameInfo.imageScale, 3)
    }
    
#elseif os(iOS)

    func test_UIKitReadImageSizeWithoutScale() throws {
        let document = VODesignDocument(fileName: documentName)
        document.updateImage(try imageWith3xScale())
        XCTAssertEqual(document.image?.size, rawSize)
        
        document.frameInfo.imageScale = 3 // Explicitly set image scale from AppKit
        XCTAssertEqual(document.imageSize, scaledSize)
    }
#endif

}
