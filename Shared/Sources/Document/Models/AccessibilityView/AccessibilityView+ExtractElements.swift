import Foundation

extension Array where Element == any AccessibilityView {
    public func extractElements() -> [A11yDescription] {
        reduce([A11yDescription]()) { result, next in
            var newResult = result
            
            switch next.cast {
            case .frame(let frame):
                newResult.append(contentsOf: frame.controls.extractElements())
            case .container(let container):
                newResult.append(contentsOf: container.elements)
            case .element(let element):
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
    
    public func extractFrames() -> [Frame] {
        compactMap { view in
            view as? Frame
        }
    }
}

