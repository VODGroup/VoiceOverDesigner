import TextRecognition
import Foundation
import CoreGraphics

import XCTest
import Document

public class FakeRecognitionImageSource {
    
    public func setImage(name: String) {
        guard let image = Bundle.module
            .image(forResource: name)
        else {
            XCTFail("\(name) file is Missing.")
            return
        }
        
        var frame = CGRect(
            origin: .zero,
            size: image.size)
        
        guard let cgImage = image
            .cgImage(forProposedRect: &frame,
                     context: nil,
                     hints: nil)
        else {
            XCTFail("Can't convert to cgImage")
            return
        }
        
        resultImage = cgImage
    }
    
    private var resultImage: CGImage? = nil
    
    public init() {}
}

extension FakeRecognitionImageSource: RecognitionImageSource {
    public func image(for model: any ArtboardElement) async -> CGImage? {
        return resultImage
    }
}
