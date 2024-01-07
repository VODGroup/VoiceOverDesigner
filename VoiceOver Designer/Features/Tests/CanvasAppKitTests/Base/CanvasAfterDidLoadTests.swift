@testable import Canvas
import QuartzCore
import Document

import XCTest

class CanvasAfterDidLoadTests: CanvasPresenterTests {
    override func setUp() {
        super.setUp()
        
        didLoadAndAppear()
    }
    
    @discardableResult
    func wrapInContainer(_ items: [A11yDescription]) -> A11yContainer? {
        sut.wrapInContainer(items)
    }
    
    func drawElement(
        from: CGPoint, to: CGPoint,
        file: StaticString = #filePath, line: UInt = #line
    ) throws -> A11yDescription {
        try XCTUnwrap(
            drawRect(from: from, to: to)?.model as? A11yDescription,
            file: file, line: line
        )
    }
    
    func selectElement(
        at coordinate: CGPoint,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws -> A11yDescription {
        click(coordinate)
        let selected = try await awaitSelected()
        let element = try XCTUnwrap(selected as? A11yDescription, file: file, line: line)
        return element
    }
    
    func selectContainer(
        at coordinate: CGPoint,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws -> A11yContainer {
        click(coordinate)
        let selected = try await awaitSelected()
        let container = try XCTUnwrap(selected as? A11yContainer, file: file, line: line)
        return container
    }
}
