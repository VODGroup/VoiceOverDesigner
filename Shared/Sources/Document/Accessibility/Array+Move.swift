

// TODO: Remove duplication of functions
extension Array where Element == A11yDescription {
    /// - Returns: From and To indexes
    @discardableResult
    public mutating func move(_ element: Element, to: Int) -> Bool {
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

    /// - Returns: From and To indexes
    public mutating func move(
        _ element: A11yDescription, 
        fromContainer: A11yContainer?,
        toIndex: Int, 
        toContainer: A11yContainer?
    ) {
        if fromContainer == toContainer {
            if let fromContainer {
                fromContainer.move(element,
                                   to: toIndex)
            } else {
                move(element, to: toIndex)
            }
        }
        
        if let toContainer {
            // Insert in container
            toContainer.insert(element, at: toIndex)
        } else {
            insert(element, at: toIndex)
        }
        
        if let fromContainer {
            _ = fromContainer.remove(element)
        } else {
            remove(element)
        }
    }
}
        
extension Array where Element == A11yDescription {

    /// - Returns: Element index
    @discardableResult
    public mutating func remove(_ element: Element) -> Int? {
        let fromIndex = firstIndex(where: { control in
            control === element
        })

        if let fromIndex {
            remove(at: fromIndex)
            return fromIndex
        }

        return nil
    }
}
