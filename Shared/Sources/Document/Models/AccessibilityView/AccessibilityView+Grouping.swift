import Foundation

extension Array where Element == any AccessibilityView {
    public mutating func wrapInContainer(indexes: IndexSet) {
        let element = remove(at: indexes.first!) as! A11yDescription
        
        append(A11yContainer(elements: [element],
                             frame: element.frame,
                             label: "Test"))
    }
}
