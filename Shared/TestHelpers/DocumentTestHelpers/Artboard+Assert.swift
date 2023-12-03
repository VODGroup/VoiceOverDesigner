import Document
import XCTest
import CustomDump

extension Artboard {
    public func assert(
        _ expected: String,
        _ message: String = "",
        file: StaticString = #file, line: UInt = #line
    ) {
        let actual = elements.recursiveDescription().joined(separator: "\n")
        
        XCTAssertNoDifference(
            actual,
            expected,
            message,
            file: file, line: line)
    }
}

extension Array where Element == any ArtboardElement {
    func assert(
        _ expected: String...,
        file: StaticString = #file, line: UInt = #line
    ) {
        let actual = recursiveDescription()
        XCTAssertNoDifference(actual,
                              expected,
                              file: file, line: line)
    }
    
    func recursiveDescription(insetLevel: Int = 0) -> [String] {
        
        let inset = String(repeating: " ", count: insetLevel)
        
        return map { view in
            switch view.cast {
            case .frame(let frame):
                if frame.elements.isEmpty {
                    return frame.label
                }
                
                return "\(frame.label):\n\(frame.elements.elementsDescription(insetLevel + 1))"
            case .container(let container):
                if container.elements.isEmpty {
                    return inset + container.label
                }
                
                let containerDesc = inset + "\(container.label):\n\(container.elements.elementsDescription(insetLevel + 1))"
                return containerDesc
            case .element(let element):
                return inset + element.label
            }
        }
    }
    
    func elementsDescription(_ insetLevel: Int) -> String {
        return recursiveDescription(insetLevel: insetLevel)
        .joined(separator: "\n")
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
