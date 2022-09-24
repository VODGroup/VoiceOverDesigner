import Foundation
import CoreGraphics
import Document

class TextRecognitionController {
    let textRecognitionService = TextRecognitionService()
    
    // TODO: Make dynamic scale
    func update(image: CGImage?, control: A11yControl) async {
        guard let image = image else { return }
        
        self.textRecognitionService.processImage(image: image)
    }
}
