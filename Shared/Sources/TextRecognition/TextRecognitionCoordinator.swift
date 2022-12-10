import Document
import CoreGraphics

public protocol RecognitionImageSource: AnyObject {
    func image(for model: any AccessibilityView) async -> CGImage?
}

public class TextRecognitionCoordinator {
    public init(
        imageSource: RecognitionImageSource?
    ) {
        self.imageSource = imageSource
    }
    
    private let textRecognition = TextRecognitionService()
    private weak var imageSource: RecognitionImageSource?
    
    public func recongizeText(
        for model: any AccessibilityView
    ) async throws -> RecognitionResult {
        guard let backImage = await imageSource?.image(for: model)
        else { throw RecognitionImageError.cantExtractImage }
        
        let recognitionResults = try await textRecognition.processImage(image: backImage)
        
        let results = RecognitionResult(
            control: model,
            text: recognitionResults)
        
        return results
    }
    
    public enum RecognitionImageError: Error {
        case cantExtractImage
    }
}
