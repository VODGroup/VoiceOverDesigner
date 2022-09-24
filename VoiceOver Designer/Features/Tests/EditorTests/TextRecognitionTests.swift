@testable import Editor
import Document
import DocumentTestHelpers
import CoreGraphics
import XCTest

class TextRecognitionTests: EditorAfterDidLoadTests {
    func test_whenDrawElement_shouldReturn() async throws {
        editorUI.image = .empty()
        textRecognition.recognitioResult = ["Test result"]
        
        drawRect_10_60()
        
        let result = try await awaitPublisher(sut.recognitionPublisher)
        XCTAssertEqual(result?.text, ["Test result"])
    }
}
