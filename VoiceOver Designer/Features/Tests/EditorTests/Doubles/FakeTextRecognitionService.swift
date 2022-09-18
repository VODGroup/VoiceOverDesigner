@testable import Editor
import CoreGraphics

class FakeTextRecognitionService: TextRecognitionServiceProtocol {
    var recognitioResult = [String]()
    
    func processImage(image: CGImage) async throws -> [String] {
        return recognitioResult
    }
}
