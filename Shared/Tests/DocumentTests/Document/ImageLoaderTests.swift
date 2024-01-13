import XCTest

import Document
import DocumentTestHelpers

class ImageLoadTests: XCTestCase {
    
    var sut: ImageLoader!
    var frame: Frame!
    
    lazy var singleTimeOptions: XCTMeasureOptions = {
        let options = XCTMeasureOptions()
        options.iterationCount = 1
        return options
    }()
    
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let documentName = FileSample.artboard
        
        let documentPath = Sample().documentPath(name: documentName)
        sut = ImageLoader(documentPath: { documentPath })
        
        let document = try Sample().document(name: documentName, testCase: self)
        
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
        var rect: CGRect = .zero
        cgImage(forProposedRect: &rect, context: nil, hints: nil)
    }
}
