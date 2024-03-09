import Document
import XCTest
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
        let actual = elements.recursiveDescription(keyPath: \.label).joined(separator: "\n")

        assertInlineSnapshot(
            of: actual,
            as: .lines,
            message: message,
            matches: expected,
            file: file, function: function, line: line, column: column)
    }
    
    public func assertModelFrames(
        _ message: String = "",
        matches expected: (() -> String)? = nil,
        file: StaticString = #filePath,
        function: StaticString = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let actual = elements.recursiveDescription(keyPath: \.frameDescription).joined(separator: "\n")
        
        assertInlineSnapshot(
            of: actual,
            as: .lines,
            message: message,
            matches: expected,
            file: file, function: function, line: line, column: column)
    }
}

extension Array where Element == any ArtboardElement {
    public func recursiveDescription(
        insetLevel: Int = 0,
        keyPath: KeyPath<Element, String>
    ) -> [String] {
        
        let inset = String(repeating: " ", count: insetLevel)
        
        return map { view in
            switch view.cast {
            case .frame(let frame):
                if frame.elements.isEmpty {
                    return frame[keyPath: keyPath]
                }
                
                return "\(frame[keyPath: keyPath]):\n\(frame.elements.elementsDescription(insetLevel + 1, keyPath: keyPath))"
            case .container(let container):
                if container.elements.isEmpty {
                    return inset + container.label
                }
                
                let containerDesc = inset + "\(container[keyPath: keyPath]):\n\(container.elements.elementsDescription(insetLevel + 1, keyPath: keyPath))"
                return containerDesc
            case .element(let element):
                return inset + element[keyPath: keyPath]
            }
        }
    }
    
    func elementsDescription(
        _ insetLevel: Int,
        keyPath: KeyPath<Element, String>
    ) -> String {
        return recursiveDescription(insetLevel: insetLevel,
                                    keyPath: keyPath)
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

extension ArtboardElement {
    var frameDescription: String {
        "\(label): \(frame.debugDescription)"
    }
}
