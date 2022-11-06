@testable import Canvas
import CoreGraphics
import TextRecognition

class FakeTextRecognitionService: TextRecognitionServiceProtocol {
    var recognitioResult = [String]()
    
    func processImage(image: CGImage) async throws -> [String] {
        return recognitioResult
    }
}
