extension A11yDescription {
    public func addAdjustableOption(defaultValue: String = "") {
        trait.formUnion(.adjustable)
        adjustableOptions.add(defaultValue: defaultValue)
    }
    
    public func updateAdjustableOption(at index: Int, with text: String) {
        adjustableOptions.update(at: index, text: text)
    }
    
    public func removeAdjustableOption(at index: Int) {
        adjustableOptions.remove(at: index)
        if adjustableOptions.isEmpty {
            trait.remove(.adjustable)
        }
    }
    
    public func selectAdjustableOption(at index: Int) {
        adjustableOptions.currentIndex = index
        value = adjustableOptions.options[index]
    }
    
    public func accessibilityIncrement() {
        adjustableOptions.accessibilityIncrement()
        value = adjustableOptions.currentValue ?? ""
    }
    
    public func accessibilityDecrement() {
        adjustableOptions.accessibilityDecrement()
        value = adjustableOptions.currentValue ?? ""
    }
}
