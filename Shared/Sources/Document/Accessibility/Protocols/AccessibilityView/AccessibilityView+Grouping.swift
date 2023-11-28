import Foundation
import Artboard

private let NSOutlineViewDropOnItemIndex = -1

extension Artboard {
    
    public func drag(
        _ draggingElement: any ArtboardElement,
        over dropElement: (any ArtboardElement)?,
        insertionIndex: Int,
        undoManager: UndoManager?
    ) -> Bool {
        
        // TODO: Add redo
        switch (dropElement, insertionIndex) {
        
        // Avoid NSOutlineViewDropOnItemIndex at the beginning
        // Drop on element to create container
        case (let secondElement as A11yDescription, NSOutlineViewDropOnItemIndex):
            wrapInContainer(
                [draggingElement, secondElement],
                undoManager: undoManager)
            
            return true
            
        // Move inside container
        case (let container as any ArtboardContainer, insertionIndex):
            move(draggingElement,
                 inside: container,
                 insertionIndex: insertionIndex,
                 undoManager: undoManager)
            
            return true
        
        // Move element on artboard's level
        case (nil, insertionIndex):
            moveElementOnArtboardLevel(
                draggingElement: draggingElement,
                insertionIndex: insertionIndex,
                undoManager: undoManager)
            
            return true
        
        default:
            return false
        }
    }
    
    func move(
        _ element: any ArtboardElement,
        inside container: any ArtboardContainer,
        insertionIndex: Int,
        undoManager: UndoManager?
    ) {
        let insertionParentOfDragging = element.parent
        var insertionIndexOfDraggingForUndo: Int? = nil

        let moveToArtboardLevel = insertionIndex == NSOutlineViewDropOnItemIndex // TODO: Make it optional
        if moveToArtboardLevel {
            container.elements.append(element)
        } else {
            let inSameContainer = container === element.parent
            if inSameContainer {
                container.elements.move(element, to: insertionIndex)
            } else {
                // Diferent containers
                insertionIndexOfDraggingForUndo = element.removeFromParent()
                container.elements.insert(element, at: insertionIndex)
                
            }
        }
        
        undoManager?.registerUndo(withTarget: self, handler: { artboard in
            container.elements.remove(element)
            insertionParentOfDragging?.elements.insert(
                element,
                at: insertionIndexOfDraggingForUndo!)
        })
    }
    
    public func wrapInContainer(
        _ elements: [any ArtboardElement],
//        _ firstElement: any ArtboardElement,
//        _ secondElement: any ArtboardElement,
        undoManager: UndoManager?
    ) -> A11yContainer {
        let insertionParentOfDragging = elements.first?.parent
//        let insertionParent2 = secondElement.parent
//        let insertionIndexForUndo2 = secondElement.removeFromParent()
        let insertionIndexOfDraggingForUndo = elements.first?.removeFromParent()
//        
        for element in elements.reversed() {
            element.removeFromParent()
        }
//        let elements = [firstElement, secondElement]
        
        let container = A11yContainer(
            elements: elements,
            frame: elements
                .map(\.frame)
                .commonFrame
                .insetBy(dx: -20, dy: -20),
            label: "Container")
        container.parent = insertionParentOfDragging ?? self
        
        insertionParentOfDragging?.elements.insert(container, at: insertionIndexOfDraggingForUndo!) // TODO: Если оба элемента в одном контейнере, то они могут сместиться на -1. Или нет, если первый элемент был после второго
        
        self.elements.removeEmptyContainers()
        
        undoManager?.registerUndo(withTarget: self, handler: { artboard in
            _ = container.removeFromParent()
//            insertionParentOfDragging?.elements.insert(
//                firstElement,
//                at: insertionIndexOfDraggingForUndo!)
//            insertionParent2?.elements.insert(
//                secondElement,
//                at: insertionIndexForUndo2!)
        })
        
        return container
    }
    
    func moveElementOnArtboardLevel(
        draggingElement: any ArtboardElement,
        insertionIndex: Int,
        undoManager: UndoManager?
    ) {
        let insertionParentOfDragging = draggingElement.parent
        elements.insert(draggingElement, at: insertionIndex)
        
        let insertionIndexOfDraggingForUndo = draggingElement.removeFromParent()
        
        undoManager?.registerUndo(withTarget: self, handler: { artboard in
            _ = draggingElement.removeFromParent()
            insertionParentOfDragging?.elements.insert(
                draggingElement,
                at: insertionIndexOfDraggingForUndo!)
        })
    }
}

extension Frame {
    @discardableResult
    public func wrap<Container: ArtboardContainer & InstantiatableContainer>(
        in type: Container.Type,
        _ items: [any ArtboardElement],
        label:  String
    ) -> Container? {
        guard items.count > 0 else { return nil }
        
        var extractedElements = [any ArtboardElement]()
        
        var insertIndex: Int?
        for item in items.reversed() {
            guard let index = item.removeFromParent() else {
                continue
            }
            
            insertIndex = index // We used reversed order and the last set will be first index
            
            extractedElements.append(item)
        }
        
        let container = Container(
            elements: extractedElements.reversed(),
            frame: extractedElements
                .map(\.frame)
                .commonFrame
                .insetBy(dx: -20, dy: -20),
            label: label)
        
        elements.insert(container, at: insertIndex ?? 0)
        
        elements.removeEmptyContainers()
        
        return container
    }
}

extension ArtboardElement {
    fileprivate func removeFromParent() -> Int? {
        parent?.elements.remove(self)
    }
}

extension Array where Element == any ArtboardElement {
    
    @discardableResult
    public mutating func wrap<Container: ArtboardContainer & InstantiatableContainer>(
        in type: Container.Type,
        _ items: [any ArtboardElement],
        label:  String
    ) -> Container? {
        guard items.count > 0 else { return nil }

        var extractedElements = [any ArtboardElement]()

        var insertIndex: Int?
        for item in items.reversed() {
            guard let index = removeFromContainers(item) ?? remove(item) else {
                continue
            }
            
            insertIndex = index // We used reversed order and the last set will be first index
                
            extractedElements.append(item)
        }

        let container = Container(
            elements: extractedElements.reversed(),
            frame: extractedElements
                .map(\.frame)
                .commonFrame
                .insetBy(dx: -20, dy: -20),
            label: label)

        insert(container, at: insertIndex ?? 0)
        
        removeEmptyContainers()
        
        return container
    }
    
    fileprivate mutating func removeEmptyContainers() {
        forEachContainer { containerIndex, container in
            if container.elements.isEmpty {
                remove(at: containerIndex)
            }
        }
    }
    
    public mutating func unwrapContainer(_ container: A11yContainer) {
        guard let containerIndex = remove(container) else { return }
        insert(contentsOf: container.elements.reversed(), at: containerIndex)
    }
    
    /// - Returns: Container index
    mutating func removeFromContainers(_ item: any ArtboardElement) -> Int? {
        for (containerIndex, view) in enumerated().reversed() {
            guard let container = view as? A11yContainer
            else { continue }
            
            guard let _ = container.remove(item)
            else { continue }
            
            return containerIndex
        }
        
        return nil
    }
    
    func forEachContainer(
        _ iterator: (_ containerIndex: Int, _ container: A11yContainer) -> Void
    ) {
        for (containerIndex, view) in enumerated().reversed() {
            guard let container = view as? A11yContainer
            else { continue }
            
            iterator(containerIndex, container)
        }
    }
}

extension Array where Element == CGRect {
    var commonFrame: CGRect {
        var result = first!
        
        for rect in self.dropFirst() {
            result = result.union(rect)
        }
        
        return result
    }
}

public extension Array where Element == any ArtboardElement {
    func container(for description: A11yDescription) -> A11yContainer? {
        extractContainers().first(where: {
            $0.contains(description)
        })
    }
}


public extension Array where Element == any ArtboardElement {
    
    // Delete only top-level elements
    @discardableResult
    mutating func delete(_ description: A11yDescription) -> Int?  {
        let indexToDelete = firstIndex(where: {
            $0 === description
        })
        
        guard let indexToDelete
        else { return nil }
        
        // Delete on top level
        remove(at: indexToDelete)
        return indexToDelete
    }
    
    // Deletes children
    @discardableResult
    mutating func delete(_ container: A11yContainer) -> Int? {
        guard let indexToDelete = firstIndex(where: {
            $0 === container
        }) else { return nil }
        
        remove(at: indexToDelete)
        return indexToDelete
    }
}

extension Artboard {
    public typealias InsertionContext = ((any ArtboardContainer)?, Int)
    public func remove(
        _ model: any ArtboardElement
    ) -> InsertionContext? {
        if let parent = model.parent {
            if let insertionIndex = parent.elements.remove(model) {
                return (parent, insertionIndex)
            }
        } else {
            if let insertionIndex = elements.remove(model) {
                return (self, insertionIndex)
            }
        }
        
        assertionFailure("Can't find parent to remove")
        return nil // Can't find to remove
    }
}
