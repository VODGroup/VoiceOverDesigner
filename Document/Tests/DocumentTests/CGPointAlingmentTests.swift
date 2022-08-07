//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 27.07.2022.
//

@testable import Document
import XCTest
import CoreGraphics

class CGPointAlingmentTests: XCTestCase {
    
    let rect = CGRect(origin: CGPoint.coord(10),
                      size: CGSize.side(10))
    
    func test_noAlingment() {
        assertAlingment(
            .coord(100),
            [])
    }
    
    func testMinXAlingment() throws {
        assertAlingment(
            .coord(9),
            [AlingmentPoint(value: 10.0, direction: .minX, frame: rect),
             AlingmentPoint(value: 10.0, direction: .minY, frame: rect)])
    }
    
    func testMaxXAlingment() throws {
        assertAlingment(
            .coord(21),
            [AlingmentPoint(value: 20, direction: .maxX, frame: rect),
             AlingmentPoint(value: 20, direction: .maxY, frame: rect)])
    }
    
    func testMinYAlingment() throws {
        assertAlingment(
            CGPoint(x: 30, y: 7),
            [AlingmentPoint(value: 10.0, direction: .minY, frame: rect)])
    }
    
    func testMaxYAlingment() throws {
        assertAlingment(
            CGPoint(x: 30, y: 21),
            [AlingmentPoint(value: 20.0, direction: .maxY, frame: rect)])
    }
    
    func assertAlingment(
        _ point: CGPoint,
        _ expectedAlingment: [AlingmentPoint],
        file: StaticString = #file, line: UInt = #line
    ) {
        let alingment = point.aligned(to: rect)

        XCTAssertEqual(alingment, expectedAlingment, file: file, line: line)
    }
}



extension AlingmentDirection: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .minX: return ".minX"
        case .minY: return ".minY"
        case .maxX: return ".maxX"
        case .maxY: return ".maxY"
        }
    }
}
