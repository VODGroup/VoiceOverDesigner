import XCTest
import Document
import DocumentTestHelpers

final class DocumentImage_ScaleTests: XCTestCase {

    let scaledSize = CGSize(width: 390, height: 180)
    let rawSize = CGSize(width: 1170, height: 540)
    
    let imageName = Sample.image3xScale
    let documentName = "TestFile1"
    
    // No test saved document, but keep it here for feature tests
//    override func tearDownWithError() throws {
//        try super.tearDownWithError()
//
//        try VODesignDocument.removeTestDocument(name: documentName)
//    }
    
    func imageWith3xScale(file: StaticString = #file, line: UInt = #line) throws -> Image {
        let imageWith3xScale = try XCTUnwrap(Sample().image(name: imageName))
        
#if os(macOS)
        XCTAssertEqual(imageWith3xScale.size, scaledSize, file: file, line: line)
        XCTAssertEqual(imageWith3xScale.recommendedLayerContentsScale(1), 3, file: file, line: line)
        return imageWith3xScale
#elseif os(iOS)
        XCTAssertEqual(imageWith3xScale.size, rawSize, "imaga size doesn't know about scale", file: file, line: line)
        XCTAssertEqual(imageWith3xScale.scale, 1, file: file, line: line)
        return imageWith3xScale
#endif
    }
    
#if os(macOS)
    func test_APPKit_whenCreateFileFromImage_shouldSetImageSizeWithScale() throws {
        let document = VODesignDocument(image: try imageWith3xScale())

        let frame = try XCTUnwrap(document.artboard.frames.first)
        XCTAssertEqual(
            frame.frame,
            CGRect(origin: .zero,
                   size: scaledSize),
            "Frame should be scaled")
    }
    
    func test_APPKit_whenUpdateImageExternaly_shouldSetImageSizeWithScale() throws {
        let document = try VODesignDocument(type: uti)
        
        document.addFrame(with: try imageWith3xScale(), origin: .zero)
        
        let frame = try XCTUnwrap(document.artboard.frames.first)
        XCTAssertEqual(
            frame.frame,
            CGRect(origin: .zero,
                   size: scaledSize),
            "Frame should be scaled")
    }
    
    func test_whenAddImage_shouldCreateFrameOfImageSize() throws {
        let document = try VODesignDocument(type: uti)
        
        document.addFrame(with: try imageWith3xScale(), origin: .zero)
        
        let frame = try XCTUnwrap(document.artboard.frames.first, "should create frame from image")
        XCTAssertEqual(frame.frame, CGRect(origin: .zero, size: scaledSize), "should use scaled frame")
    }
    
    // TODO: Second image should add another frame
    
#elseif os(iOS)

    func test_UIKitReadImageSizeWithoutScale() throws {
        let document = VODesignDocument(fileName: documentName)
        document.addFrame(with: try imageWith3xScale())
        XCTAssertEqual(document.image?.size, rawSize)
        
        document.frameInfo.imageScale = 3 // Explicitly set image scale from AppKit
        XCTAssertEqual(document.imageSize, scaledSize)
    }
#endif

}
