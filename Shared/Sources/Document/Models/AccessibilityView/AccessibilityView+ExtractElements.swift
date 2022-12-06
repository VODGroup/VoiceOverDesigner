import Foundation

extension Array where Element == any AccessibilityView {
    public func extractElements() -> [A11yDescription] {
        reduce([A11yDescription]()) { result, next in
            var newResult = result
            if let container = next as? A11yContainer {
                newResult.append(contentsOf: container.elements)
            } else if let element = next as? A11yDescription {
                newResult.append(element)
            }
            return newResult
        }
    }
    
    public func extractContainers() -> [A11yContainer] {
        compactMap { view in
            view as? A11yContainer
        }
    }
}

