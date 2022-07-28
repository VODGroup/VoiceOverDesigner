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
    
    func testMinXAlingment() throws {
        let point = CGPoint.coord(9)
        
        try assertAlingment(point,
                            CGPoint(x: 10, y: 9), // Alinged X only, but should be both
                            .minX)
    }
    
    func testMaxXAlingment() throws {
        let point = CGPoint.coord(21)
        
        try assertAlingment(point,
                            CGPoint(x: 20, y: 21), // Alinged X only, but should be both
                            .maxX)
    }
    
    func testMinYAlingment() throws {
        let point = CGPoint(x: 30, y: 7)
        
        try assertAlingment(point,
                            CGPoint(x: 30, y: 10), // Alinged Y only and X should be far away
                            .minY)
    }
    
    func testMaxYAlingment() throws {
        let point = CGPoint(x: 30, y: 21)
        
        try assertAlingment(point,
                            CGPoint(x: 30, y: 20), // Alinged Y only and X should be far away
                            .maxY)
    }
    
    
    func assertAlingment(
        _ point: CGPoint, _ expectedAlingedPoint: CGPoint, _ expectedEdge: NSRectEdge,
        file: StaticString = #file, line: UInt = #line
    ) throws {
        let (resultPoint, edge) = try XCTUnwrap(point.aligned(to: rect), file: file, line: line)
        
        XCTAssertEqual(resultPoint, expectedAlingedPoint, file: file, line: line)
        XCTAssertEqual(edge, expectedEdge, file: file, line: line)
    }
}

extension NSRectEdge: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .minX: return "minX"
        case .minY: return "minY"
        case .maxX: return "maxX"
        case .maxY: return "maxY"
        @unknown default: return "unknown default"
        }
    }
}
