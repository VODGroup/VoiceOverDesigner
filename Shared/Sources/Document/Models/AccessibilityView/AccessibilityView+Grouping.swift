import Foundation

extension Array where Element == any AccessibilityView {
    public mutating func wrapInContainer(indexes: IndexSet) {
        guard indexes.count > 0 else { return }
        
        var extractedElements = [A11yDescription]()
        
        for index in indexes.reversed() {
            let element = remove(at: index) as! A11yDescription
            extractedElements.append(element)
        }
        
        let container = A11yContainer(
            elements: extractedElements,
            frame: extractedElements.map(\.frame).commonFrame,
            label: "Test")
        
        insert(container, at: indexes.first!)
    }
}

extension Array where Element == CGRect {
    var commonFrame: CGRect {
        var result = first!
        
        for rect in self.dropFirst() {
            result = result.union(rect)
        }
        
        return result
    }
}
