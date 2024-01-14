@testable import Document
import CoreGraphics
import Foundation

import XCTest

class FrameInfoCodableTests: XCTestCase {
    func test() throws {
        let sut = FrameInfo(
            id: UUID(uuidString: "9B2125D5-EA06-4E91-AFBF-1D4698158851")!,
            imageScale: 1,
            frame: CGRect(origin: .zero,
                          size: CGSize(width: 100, height: 200)))
        
        let result = try decodeAndEncode(sut)
        
        XCTAssertEqual(sut.id, result.id)
        XCTAssertEqual(sut.imageScale, result.imageScale)
        XCTAssertEqual(sut.frame, result.frame)
    }
    
    private func decodeAndEncode<T: Codable>(_ model: T) throws -> T {
        let data = try JSONEncoder().encode(model)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
