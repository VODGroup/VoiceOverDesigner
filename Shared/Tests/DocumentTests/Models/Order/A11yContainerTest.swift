import XCTest
import Document
import Artboard

class A11yContainerTest: XCTestCase {
    
    func test_containerWithSingleButton_cantTraitAsAdjustable() {
        let container = A11yContainer.testMake(
            elements: [
                .testMake(label: "Small", trait: .button),
            ], label: "Size")
        
        XCTAssertFalse(container.canTraitAsAdjustable)
        
        container.treatButtonsAsAdjustable = true
        XCTAssertFalse(container.canTraitAsAdjustable, "No affect")
        
        let proxy = container.adjustableProxy
        XCTAssertNil(proxy)
    }
    
    func test_containerHas3Buttons_whenTraitAsAdjustable_shouldGenerateProxyWith3Options() {
        let container = A11yContainer.testMake(
            elements: [
                .testMake(label: "Small", trait: .button),
                .testMake(label: "Middle", trait: .button),
                .testMake(label: "Large", trait: .button),
            ], label: "Size")
        
        container.treatButtonsAsAdjustable = true
        
        let proxy = container.adjustableProxy
        XCTAssertNotNil(proxy)
        
        XCTAssertEqual(proxy?.adjustableOptions.options.count, 3)
        XCTAssertEqual(proxy?.adjustableOptions.currentIndex, 0)
    }
}
