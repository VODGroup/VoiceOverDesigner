import Foundation

extension Array where Element == any AccessibilityView {
    
    @discardableResult
    public mutating func wrapInContainer(
        _ items: [A11yDescription],
        label:  String
    ) -> A11yContainer? {
        guard items.count > 0 else { return nil }

        var extractedElements = [A11yDescription]()

        var insertIndex: Int?
        for item in items.reversed() {
            guard let index = remove(item) ?? removeFromContainers(item) else {
                continue
            }
            
            insertIndex = index // We used reveersed order and the last set will be first index
                
            extractedElements.append(item)
        }

        let container = A11yContainer(
            elements: extractedElements,
            frame: extractedElements
                .map(\.frame)
                .commonFrame
                .insetBy(dx: -20, dy: -20),
            label: label)

        insert(container, at: insertIndex ?? 0)
        
        removeEmptyContainers()
        
        return container
    }
    
    
    public mutating func unwrapContainer(_ container: A11yContainer) {
        guard let containerIndex = remove(container) else { return }
        insert(contentsOf: container.elements.reversed(), at: containerIndex)
    }
    
    /// - Returns: Container index
    mutating func removeFromContainers(_ item: A11yDescription) -> Int? {
        for (containerIndex, view) in enumerated().reversed() {
            guard let container = view as? A11yContainer
            else { continue }
            
            guard let _ = container.remove(item)
            else { continue }
            
            return containerIndex
        }
        
        return nil
    }
    
    func forEachContainer(
        _ iterator: (_ containerIndex: Int, _ container: A11yContainer) -> Void
    ) {
        for (containerIndex, view) in enumerated().reversed() {
            guard let container = view as? A11yContainer
            else { continue }
            
            iterator(containerIndex, container)
        }
    }
    
    private mutating func removeEmptyContainers() {
        forEachContainer { containerIndex, container in
            if container.elements.isEmpty {
                remove(at: containerIndex)
            }
        }
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

public extension Array where Element == any AccessibilityView {
    func container(for description: A11yDescription) -> A11yContainer? {
        extractContainers().first(where: {
            $0.contains(description)
        })
    }
}


public extension Array where Element == any AccessibilityView {
    
    // Delete only top-level elements
    @discardableResult
    mutating func delete(_ description: A11yDescription) -> Int?  {
        let indexToDelete = firstIndex(where: {
            $0 === description
        })
        
        guard let indexToDelete
        else { return nil }
        
        // Delete on top level
        remove(at: indexToDelete)
        return indexToDelete
    }
    
    // Deletes children
    @discardableResult
    mutating func delete(_ container: A11yContainer) -> Int? {
        guard let indexToDelete = firstIndex(where: {
            $0 === container
        }) else { return nil }
        
        remove(at: indexToDelete)
        return indexToDelete
    }
}
