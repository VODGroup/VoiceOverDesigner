import Foundation

extension Array where Element == any AccessibilityView {
    public mutating func wrapInContainer(_ items: [any AccessibilityView], label:  String) {
        guard items.count > 0 else { return }

        var extractedElements = [A11yDescription]()

        for item in items.reversed() {
            guard let index = firstIndex(where: { element in
                element === item
            }) else {
                continue
            }
            
            let element = remove(at: index) as! A11yDescription
            extractedElements.append(element)
        }

        let container = A11yContainer(
            elements: extractedElements,
            frame: extractedElements.map(\.frame).commonFrame,
            label: label)

        insert(container, at: 0)
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
