import Foundation

extension Array where Element == any ArtboardElement {
    public func extractElements() -> [A11yDescription] {
        reduce([A11yDescription]()) { result, next in
            var newResult = result
            
            switch next.cast {
            case .frame(let frame):
                newResult.append(contentsOf: frame.elements.extractElements())
            case .container(let container):
                newResult.append(contentsOf: container.controls)
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

