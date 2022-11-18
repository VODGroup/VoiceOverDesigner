//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 27.07.2022.
//

@testable import Canvas
import XCTest
import CoreGraphics

class CGPointAlignmentTests: XCTestCase {
    
    let rect = CGRect(origin: CGPoint.coord(10),
                      size: CGSize.side(10))
    
    func test_noAlignment() {
        assertAlignment(
            .coord(100),
            [])
    }
    
    func testMinXAlignment() throws {
        assertAlignment(
            .coord(9),
            [AlignmentPoint(value: 10.0, direction: .minX, frame: rect),
             AlignmentPoint(value: 10.0, direction: .minY, frame: rect)])
    }
    
    func testMaxXAlignment() throws {
        assertAlignment(
            .coord(21),
            [AlignmentPoint(value: 20, direction: .maxX, frame: rect),
             AlignmentPoint(value: 20, direction: .maxY, frame: rect)])
    }
    
    func testMinYAlignment() throws {
        assertAlignment(
            CGPoint(x: 30, y: 7),
            [AlignmentPoint(value: 10.0, direction: .minY, frame: rect)])
    }
    
    func testMaxYAlignment() throws {
        assertAlignment(
            CGPoint(x: 30, y: 21),
            [AlignmentPoint(value: 20.0, direction: .maxY, frame: rect)])
    }
    
    func assertAlignment(
        _ point: CGPoint,
        _ expectedAlignment: [AlignmentPoint],
        file: StaticString = #file, line: UInt = #line
    ) {
        let alignment = point.aligned(to: rect)

        XCTAssertEqual(alignment, expectedAlignment, file: file, line: line)
    }
}



extension AlignmentDirection: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .minX: return ".minX"
        case .maxX: return ".maxX"
        case .midX: return ".midX"
            
        case .minY: return ".minY"
        case .midY: return ".midY"
        case .maxY: return ".maxY"
        }
    }
}
