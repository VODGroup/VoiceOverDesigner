import XCTest

import Document
import DocumentTestHelpers

class ImageLoadTests: XCTestCase {
    
    var sut: ImageLoading!
    var frame: Frame!
    
    lazy var singleTimeOptions: XCTMeasureOptions = {
        let options = XCTMeasureOptions()
        options.iterationCount = 1
        return options
    }()
    
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let document = try Sample().document(name: FileSample.artboard, testCase: self)
        sut = document
        frame = try XCTUnwrap(document.artboard.frames.first!)
    }
    
    func test_noCache() throws {
        measure(metrics: [XCTClockMetric()], options: singleTimeOptions) {
            let image = sut.image(for: frame)
            
            image?.loadImage()
        }
    }
    
    func test_cache() throws {
        // No cache
        let image = sut.image(for: frame)
        image?.loadImage()
        
        // From cache
        measure(metrics: [XCTClockMetric()], options: singleTimeOptions) {
            let image = sut.image(for: frame)
            image?.loadImage()
        }
    }
}

extension NSImage {
    func loadImage() {
        var rect: CGRect = CGRect(origin: .zero, size: CGSize(width: 400, height: 1000))
        cgImage(forProposedRect: &rect, context: nil, hints: nil)
    }
}
