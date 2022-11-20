@testable import Canvas
import Document
import DocumentTestHelpers
import CoreGraphics
import XCTest

class TextRecognitionTests: CanvasAfterDidLoadTests {
    func test_whenDrawElement_shouldReturn() async throws {
        canvasUI.image = .empty()
        textRecognition.recognitioResult = ["Test result"]
        
        drawRect_10_60()
        
        let result = try await awaitPublisher(sut.recognitionPublisher)
        XCTAssertEqual(result?.text, ["Test result"])
    }
}
