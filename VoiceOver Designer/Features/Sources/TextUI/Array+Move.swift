import Document

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
