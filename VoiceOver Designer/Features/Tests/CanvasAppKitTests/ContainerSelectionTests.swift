import XCTest
@testable import Canvas

@MainActor
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
        
        let container = wrapInContainer([element1, element2])
        
        let selectedContainer = try await selectContainer(at: .coord(100))
        XCTAssertEqual(container, selectedContainer)
    }
    
    func test_2elements_whenWrappInContainer_andUndo_shouldRestoreElementsOnTopLevel() async throws {
        sut.disableUndoRegistration()
        let element1 = try drawElement(from: start10, to: end60)
        let element2 = try drawElement(from: .coord(150), to: .coord(200))
        sut.enableUndoRegistration()
        
        drawingLayer.assertRelativeFrames {
            """
            ControlLayer: (10.0, 10.0, 50.0, 50.0)
            ControlLayer: (150.0, 150.0, 50.0, 50.0)
            """
        }
        
        wrapInContainer([element1, element2])
        
        drawingLayer.assertRelativeFrames {
            """
            ControlLayer: (-10.0, -10.0, 230.0, 230.0)
             ControlLayer: (20.0, 20.0, 50.0, 50.0)
             ControlLayer: (160.0, 160.0, 50.0, 50.0)
            """
        }
        
        sut.undo()
        
        drawingLayer.assertRelativeFrames {
            """
            ControlLayer: (10.0, 10.0, 50.0, 50.0)
            ControlLayer: (150.0, 150.0, 50.0, 50.0)
            """
        }
    }
}
