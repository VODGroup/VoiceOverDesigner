public extension A11yDescription {
    func addCustomDescription(_ description: A11yCustomDescription) {
        customDescriptions.addNewCustomDescription(description)
    }
    
    func removeCustomDescription(at index: Int) {
        customDescriptions.remove(at: index)
    }
    
    func updateCustomDescription(at index: Int, with description: A11yCustomDescription) {
        customDescriptions.update(at: index, with: description)
    }
}
