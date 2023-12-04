import Document
import XCTest
import CustomDump
import InlineSnapshotTesting

extension Artboard {
    public func assert(
        _ message: String = "",
        matches expected: (() -> String)? = nil,
        file: StaticString = #filePath,
        function: StaticString = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let actual = elements.recursiveDescription().joined(separator: "\n")

        assertInlineSnapshot(
            of: actual,
            as: .lines,
            message: message,
            matches: expected,
            file: file, function: function, line: line, column: column)
    }
}

extension Array where Element == any ArtboardElement {
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
