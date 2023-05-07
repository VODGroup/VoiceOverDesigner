import XCTest
@testable import Canvas

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
}
