import Document

extension Array where Element == any AccessibilityView {
    /// - Returns: From and To indexes
    @discardableResult
    mutating func move(_ element: Element, to: Int) -> Bool {
        guard let from = firstIndex(where: { control in
            control === element
        }) else { return false }
        
        if to == from + 1 { // Can't move items after themselves
            return false
        }
        
        if to == from { // Can't move to same position
            return false
        }
         
        remove(at: from)
        if to > from {
            insert(element, at: to - 1)
        } else {
            insert(element, at: to)
        }
        return true
    }
}

// TODO: Remove duplication of functions
extension Array where Element == A11yDescription {
    /// - Returns: From and To indexes
    @discardableResult
    mutating func move(_ element: Element, to: Int) -> Bool {
        guard let from = firstIndex(where: { control in
            control === element
        }) else { return false }
        
        if to == from + 1 { // Can't move items after themselves
            return false
        }
        
        if to == from { // Can't move to same position
            return false
        }
         
        remove(at: from)
        if to > from {
            insert(element, at: to - 1)
        } else {
            insert(element, at: to)
        }
        return true
    }
}

extension Array where Element == any AccessibilityView {
    /// - Returns: From and To indexes
    mutating func move(
        _ element: A11yDescription, fromContainer: A11yContainer?,
        toIndex: Int, toContainer: A11yContainer?
    ) {
        if fromContainer == toContainer {
            if let fromContainer {
                fromContainer.elements.move(element,
                                            to: toIndex)
            } else {
                move(element, to: toIndex)
            }
        }
        
        if let toContainer {
            // Insert in container
            toContainer.elements.insert(element, at: toIndex)
        } else {
            insert(element, at: toIndex)
        }
        
        if let fromContainer {
            fromContainer.elements.remove(element)
        } else {
            remove(element)
        }
    }
    
    mutating func remove(_ element: Element) {
        if let from = firstIndex(where: { control in
            control === element
        }) {
            remove(at: from)
        }
    }
}
        
extension Array where Element == A11yDescription {
    mutating func remove(_ element: Element) {
        if let from = firstIndex(where: { control in
            control === element
        }) {
            remove(at: from)
        }
    }
}

