import XCTest

import TextRecognition
import TextRecognitionTestHelpers

import Document
import DocumentTestHelpers

class TextRecognitionCoordinatorTests: XCTestCase {
    
    var sut: TextRecognitionCoordinator!
    var imageSource: FakeRecognitionImageSource!
    
    let model = A11yDescription.testMake()
    
    override func setUp() async throws {
        imageSource = FakeRecognitionImageSource()
        
        sut = TextRecognitionCoordinator(imageSource: imageSource)
    }
    
    func test_nilImage_shouldReturnThrowException() async throws {
        // No image setup

        let model = A11yDescription.testMake()
        
        do {
            _ = try await sut.recongizeText(for: model)
            XCTFail("Should throw error")
        } catch {
            // Success case
        }
    }
    
    func test_realImage_shouldRecognizeText() async throws {
        imageSource.setImage(name: "RecognitionSample.png")
        
        let result = try await sut.recongizeText(for: model)
        
        XCTAssertEqual(
            result.text,
            [
                "Create your own pizza",
                "Medium, original crust",
                "Create your own pizza Medium, original crust" // Combined result also here
            ])
    }
}


