import Document
import XCTest
import CustomDump

class A11yDescriptionArrayTests: XCTestCase {
    
    var sut: [any ArtboardElement] = []
    var el1: A11yDescription!
    var el2: A11yDescription!
    var el3: A11yDescription!
    
    override func setUp() {
        super.setUp()
        
        el1 = A11yDescription.make(label: "1")
        el2 = A11yDescription.make(label: "2")
        el3 = A11yDescription.make(label: "3")
        
        sut = [
            el1,
            el2,
            el3,
        ]
    }
}

extension Array where Element == any ArtboardElement {
    func assert(
        labels: String...,
        file: StaticString = #file, line: UInt = #line
    ) {
        XCTAssertNoDifference(recursiveDescription(),
                              labels,
                              file: file, line: line)
    }
    
    func recursiveDescription() -> [String] {
        map { view in
            switch view.cast {
            case .frame(let frame):
                return frame.label // TODO: Make full description
            case .container(let container):
                if container.elements.isEmpty {
                    return container.label
                }
                
                let elementsDescription = (container.elements as [any ArtboardElement])
                    .recursiveDescription()
                    .joined(separator: ", ")
                return "\(container.label): \(elementsDescription)"
            case .element(let element):
                return element.label
            }
        }
    }
}

// TODO: Remove duplicate
extension A11yDescription {
    static func make(label: String) -> A11yDescription {
        A11yDescription(
            isAccessibilityElement: true,
            label: label,
            value: "",
            hint: "",
            trait: [],
            frame: .zero,
            adjustableOptions: AdjustableOptions(options: []),
            customActions: A11yCustomActions(names: [])
        )
    }
}
