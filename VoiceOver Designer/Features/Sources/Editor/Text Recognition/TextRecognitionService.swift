import Vision
import AppKit

class TextRecognitionService {
    
    var candidates: [String] = []
    
    lazy var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
        guard let requestResults = request.results as? [VNRecognizedTextObservation] else { return }
        
        DispatchQueue.main.async {
            self.handle(results: requestResults)
        }
    })
    
    func handle(results: [VNRecognizedTextObservation]) {
        let candidates = results.compactMap { observation in
            observation.topCandidates(1).first?.string
        }
        
        print(candidates)
    }
    
    init() {
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.usesLanguageCorrection = true
    }
    
    func processImage(image: CGImage) {
        clearCandidates()
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try handler.perform([textRecognitionRequest])
        } catch {
            print(error)
        }
    }
    
    private func clearCandidates() {
        candidates = []
    }
}

