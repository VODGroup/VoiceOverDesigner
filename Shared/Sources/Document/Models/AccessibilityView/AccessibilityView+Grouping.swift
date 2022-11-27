import Foundation

extension Array where Element == any AccessibilityView {
    public mutating func wrapInContainer(
        _ items: [A11yDescription],
        label:  String
    ) {
        guard items.count > 0 else { return }

        var extractedElements = [A11yDescription]()

        var insertIndex: Int?
        for item in items.reversed() {
            guard let index = remove(item) else {
                continue
            }
                
            insertIndex = index // We used reversed order and the last set will be first index
            
            extractedElements.append(item)
        }

        let container = A11yContainer(
            elements: extractedElements,
            frame: extractedElements
                .map(\.frame)
                .commonFrame,
            label: label)

        insert(container, at: insertIndex ?? 0)
    }
    
    mutating func remove(_ item: A11yDescription) -> Int? {
        guard let index = firstIndex(where: { element in
            element === item
        }) else {
            return nil
        }
        
        remove(at: index)
        return index
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
