public extension VODesignDocumentProtocol {
    func container(for description: A11yDescription) -> A11yContainer? {
        controls.container(for: description)
    }
}


public extension VODesignDocumentProtocol {
    mutating func delete(_ description: A11yDescription) {
        controls.delete(description)
    }
    
    #warning("Should it delete children or ungroup before deleting?")
    mutating func delete(_ container: A11yContainer) {
        controls.delete(container)
    }
}
