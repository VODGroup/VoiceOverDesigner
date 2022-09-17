import Vision
import AppKit

class TextRecognitionService {
    
    func processImage(image: CGImage) async throws -> [String] {
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest(completionHandler: { (request, error) in
                guard let requestResults = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(with: .success([]))
                    return
                }
                
                
                let candidates = requestResults.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                continuation.resume(with: .success(candidates))
            })
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            do {
                try handler.perform([request])
            } catch let error {
                continuation.resume(throwing: error)
            }
        }
    }
}

