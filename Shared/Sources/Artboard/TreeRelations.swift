import Foundation

// MARK: - Relation
public protocol Child: AnyObject {
    /// Must be `weak`
    var parent: BaseContainer? { get set }
}

// TODO: Make generic?
public protocol Container: Child {
    var elements: [any ArtboardElement] { get }
}

public protocol Node: BaseContainer, Child, Container {}

/// Base class that manages parent-child relation in Artboard
open class BaseContainer: Container {
    open private(set) var elements: [any ArtboardElement] = []
    
    public var parent: BaseContainer?

    public func append(_ child: any ArtboardElement) {
        elements.append(child)
        child.parent = self
    }
    
    public func insert(_ node: any ArtboardElement, at index: Int) {
        elements.insert(node, at: index)
        node.parent = self
    }
    
    public func move(_ node: any ArtboardElement, to index: Int) {
        elements.move(node, to: index)
    }
    
    public func remove(_ node: any ArtboardElement) -> Int? {
        elements.remove(node)
    }
    
    public func replace(_ elements: [any ArtboardElement]) {
        self.elements = elements
        setParentOfAllElementsToCurrent()
    }
    
    public init(elements: [any ArtboardElement], parent: BaseContainer? = nil) {
        self.elements = elements
        self.parent = parent
        
        setParentOfAllElementsToCurrent()
    }
    
    private func setParentOfAllElementsToCurrent() {
        for element in elements {
            element.parent = self
        }
    }
    
    public func removeEmptyContainers() {
        elements.removeEmptyContainers()
    }
    
    public func unwrapContainer(
        _ container: BaseContainer
    ) {
        guard let containerIndex: Int = elements.remove(container as! (any ArtboardElement)) // TODO: Strange casting, can't remove
        else { return }
        
        container.elements.forEach { element in
            element.parent = self
        }
        elements.insert(contentsOf: container.elements.reversed(),
                        at: containerIndex)
    }
}

extension Array where Element == any ArtboardElement {
    /// - Returns: Element index
    @discardableResult
    public mutating func remove(_ element: Element) -> Int? {
        let from = firstIndex(where: { control in
            control === element
        })
        
        if let from {
            remove(at: from)
            return from
        }
        
        return nil
    }

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
    
}

extension Array where Element == any ArtboardElement {
    mutating func removeEmptyContainers() {
        forEachContainer { containerIndex, container in
            if container.elements.isEmpty {
                remove(at: containerIndex)
            }
        }
    }
    
    func forEachContainer(
        _ iterator: (_ containerIndex: Int, _ container: BaseContainer) -> Void
    ) {
        for (containerIndex, view) in enumerated().reversed() {
            guard let container = view as? BaseContainer
            else { continue }
            
            iterator(containerIndex, container)
        }
    }
}
