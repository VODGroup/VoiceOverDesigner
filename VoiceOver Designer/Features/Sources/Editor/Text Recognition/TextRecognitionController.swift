import Foundation
import CoreGraphics
import Document

class TextRecognitionController {
    let textRecognitionService = TextRecognitionService()
    
    // TODO: Make dynamic scale
    func update(image: CGImage?, control: A11yControl) async -> [String] {
        guard let image = image else { return [] }
        
        do {
            let results = try await textRecognitionService.processImage(image: image)
            return results
        } catch let error {
            print("Recognition error: \(error)")
            return []
        }
    }
}
