import Vision
import CoreGraphics

public protocol TextRecognitionServiceProtocol {
    func processImage(image: CGImage) async throws -> [String]
}

public protocol TextRecogitionReceiver {
    func presentTextRecognition(_ alternatives: [String])
}

public class TextRecognitionService: TextRecognitionServiceProtocol {
    public init() {}
    
    public func processImage(image: CGImage) async throws -> [String] {
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
            
            request.revision = Self.latestRevision
            request.recognitionLevel = Self.recognitionLevel
            request.usesLanguageCorrection = true
            
            do {
                try handler.perform([request])
            } catch let error {
                continuation.resume(throwing: error)
            }
        }
    }
    
#if DEBUG
    static func printSupportedLanguage(at localeIdentifier: String) {
        let outputLocale = NSLocale(localeIdentifier: localeIdentifier)
        
        let languages = TextRecognitionService.supportedLanguages
            .map({ identifier in
                return outputLocale.displayName(forKey: NSLocale.Key.languageCode, value: identifier)!
            })
        
        print(languages)
    }
    
    /// Level2: ["en-US", "fr-FR", "it-IT", "de-DE", "es-ES", "pt-BR", "zh-Hans", "zh-Hant"]
    /// Level3: ["English", "French", "Italian", "German", "Spanish", "Portuguese", "Chinese", "Chinese", "Cantonese", "Korean", "Japanese", "Russian", "Ukrainian"]
    static var supportedLanguages: [String] {
        (try? VNRecognizeTextRequest
            .supportedRecognitionLanguages(for: recognitionLevel,
                                           revision: latestRevision)) ?? []
    }
#endif
    
    static var recognitionLevel: VNRequestTextRecognitionLevel = .accurate
    
    static var latestRevision: Int {
        VNRecognizeTextRequest.supportedRevisions.last ?? VNRequestRevisionUnspecified
    }
    
    static func isAutofillEnabledDefault() -> Bool {
        Locale
            .current
            .languageCode // Like "en-US"
            .map(TextRecognitionService
                .supportedLanguages
                .contains) ?? false
    }
}

