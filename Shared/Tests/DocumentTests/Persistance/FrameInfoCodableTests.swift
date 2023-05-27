@testable import Document
import CoreGraphics
import Foundation

import XCTest
import CustomDump

class FrameInfoCodableTests: XCTestCase {
    func test() throws {
        let sut = FrameInfo(
            id: UUID(uuidString: "9B2125D5-EA06-4E91-AFBF-1D4698158851")!,
            imageScale: 1,
            frame: CGRect(origin: .zero,
                          size: CGSize(width: 100, height: 200)))
        
        let actual = try decodeToString(sut)
        
        XCTAssertNoDifference(actual, """
{
  "id" : "9B2125D5-EA06-4E91-AFBF-1D4698158851",
  "imageScale" : 1,
  "frame" : [
    [
      0,
      0
    ],
    [
      100,
      200
    ]
  ]
}
""")
    }
    
    private func decodeToString(_ codable: Codable) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(codable)
        let string = String(data: data, encoding: .utf8)!
        return string
    }
}
