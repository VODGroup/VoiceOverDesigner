import Document
import XCTest
import CustomDump

extension Artboard {
    public func assert(
        labels: String...,
        file: StaticString = #file, line: UInt = #line
    ) {
        XCTAssertNoDifference(
            elements.recursiveDescription(),
            labels,
            file: file, line: line)
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
                if frame.elements.isEmpty {
                    return frame.label
                }
                
                let elementsDescription = (frame.elements as [any ArtboardElement])
                    .recursiveDescription()
                    .joined(separator: ", ")
                return "\(frame.label): \(elementsDescription)"
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
    public static func make(label: String) -> A11yDescription {
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
