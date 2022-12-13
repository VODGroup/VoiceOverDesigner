public extension A11yDescription {
    func addCustomAction(named name: String) {
        customActions.addNewCustomAction(named: name)
    }
    
    func removeCustomAction(at index: Int) {
        customActions.remove(at: index)
    }
    
    func updateCustomAction(at index: Int, with name: String) {
        customActions.update(at: index, with: name)
    }
}