import XCTest
@testable import Canvas
import Document
import DocumentTestHelpers

class ContainerSelectionTests: CanvasAfterDidLoadTests {
    
    func test_2elementsAreWrappedInContainer_whenClickOnElement_shouldSelectElement() async throws {
        let element1 = try drawElement(from: start10, to: end60)
        let element2 = try drawElement(from: .coord(100), to: .coord(150))
        
        wrapInContainer([element1, element2])
        
        let element3 = try await selectElement(at: start10)
        XCTAssertEqual(element1, element3)
    }
    
    func test_2elementsAreWrappedInContainer_whenClickBetweenElements_shouldSelectContainer() async throws {
        let element1 = try drawElement(from: start10, to: end60)
        let element2 = try drawElement(from: .coord(150), to: .coord(200))
        
        wrapInContainer([element1, element2])
        
        _ = try await selectContainer(at: .coord(100))
    }
    
    func wrapInContainer(_ items: [A11yDescription]) {
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
