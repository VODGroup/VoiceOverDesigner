import Foundation
import Artboard

private let NSOutlineViewDropOnItemIndex = -1

extension Artboard {
    
    enum DragType {
        case wrapInContainer(secondElement: A11yDescription)
        case moveInsideContainer(container: any ArtboardContainer, insertionIndex: Int)
        case moveOnArtboardLevel(insertionIndex: Int)
    }
    
    public func canDrag(
        _ draggingElement: any ArtboardElement,
        over dropElement: (any ArtboardElement)?,
        insertionIndex: Int
    ) -> Bool {
        dragType(draggingElement, over: dropElement, insertionIndex: insertionIndex) != nil
    }
    
    private func dragType(
        _ draggingElement: any ArtboardElement,
        over dropElement: (any ArtboardElement)?,
        insertionIndex: Int) -> DragType? {
            switch (dropElement, insertionIndex) {
            // Avoid NSOutlineViewDropOnItemIndex at the beginning
            case (let secondElement as A11yDescription, NSOutlineViewDropOnItemIndex):
                return .wrapInContainer(secondElement: secondElement)
                
            case (let container as any ArtboardContainer, insertionIndex):
                return .moveInsideContainer(container: container, insertionIndex: insertionIndex)
                
            case (nil, insertionIndex):
                return .moveOnArtboardLevel(insertionIndex: insertionIndex)
                
            default:
                return nil
            }
        }
    
    public func drag(
        _ draggingElement: any ArtboardElement,
        over dropElement: (any ArtboardElement)?,
        insertionIndex: Int,
        undoManager: UndoManager?
    ) -> Bool {
        
        let dragType = dragType(draggingElement, over: dropElement, insertionIndex: insertionIndex)
        switch dragType {

        case .wrapInContainer(let secondElement):
            wrapInContainer(
                [draggingElement, secondElement],
                undoManager: undoManager)
            
        case .moveInsideContainer(let container, let insertionIndex):
            move(draggingElement,
                 inside: container,
                 insertionIndex: insertionIndex,
                 undoManager: undoManager)
        
        case .moveOnArtboardLevel(let insertionIndex):
            move(draggingElement,
                 inside: self,
                 insertionIndex: insertionIndex,
                 undoManager: undoManager)
            
        default:
            return false
        }
        
        return true
    }
    
    func move(
        _ element: any ArtboardElement,
        inside container: BaseContainer,
        insertionIndex: Int,
        undoManager: UndoManager?
    ) {
        var insertionContext: InsertionContext?
        var insertionIndex = insertionIndex
        let moveToArtboardLevel = insertionIndex == NSOutlineViewDropOnItemIndex // TODO: Make it optional if -1
        
        if moveToArtboardLevel {
            insertionIndex = container.elements.count // Will append
        }
        
        let inSameContainer = container === element.parent
        if inSameContainer {
            let insertionIndexForUndo = container.elements.firstIndex(where: { anElement in
                anElement === element
            })! // TODO: Explicit unwrap
            
            container.move(element, to: insertionIndex)
            
            insertionContext = InsertionContext(element: element, parent: container, insertionIndex: insertionIndexForUndo)
        } else {
            // Diferent containers
            insertionContext = element.removeFromParent()
            container.insert(element, at: insertionIndex)
        }
        
        undoManager?.registerUndo(withTarget: self, handler: { artboard in
            container.remove(element)
            insertionContext?.restore() // Not pass undoManager because use another restoration type
            
            // Redo
            undoManager?.registerUndo(withTarget: artboard, handler: { artboard in
                artboard.move(element, inside: container, insertionIndex: insertionIndex, undoManager: undoManager)
            })
        })
    }
    
    @discardableResult
    public func wrapInContainer(
        _ elements: [any ArtboardElement],
        undoManager: UndoManager?
    ) -> A11yContainer {
        let insertionContext = elements.first?.removeFromParent(undoManager: undoManager)
        
        for element in elements
            .dropFirst()
            .reversed() {
            element.removeFromParent(undoManager: undoManager)
        }

        let container = A11yContainer(
            elements: elements,
            frame: elements
                .map(\.frame)
                .commonFrame
                .insetBy(dx: -20, dy: -20),
            label: "Container")
        
        (insertionContext?.parent ?? self)
            .insert(container, // <-- Insert container
                    at: insertionContext!.insertionIndex)
        // TODO: Если оба элемента в одном контейнере, то они могут сместиться на -1. Или нет, если первый элемент был после второго
        
        self.elements.removeEmptyContainers()
        
        undoManager?.registerUndo(withTarget: self, handler: { artboard in
            _ = container.removeFromParent()
            
            // + implicit undo from `removeFromParent`
            
            undoManager?.registerUndo(withTarget: self, handler: { artboard in
                self.wrapInContainer(elements, undoManager: undoManager)
            })
        })
        
        return container
    }
}

extension Array where Element == any ArtboardElement {

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

public class InsertionContext {
    public init(
        element: any ArtboardElement,
        parent: BaseContainer?,
        insertionIndex: Int
    ) {
        self.element = element
        self.parent = parent
        self.insertionIndex = insertionIndex
    }
    
    let element: any ArtboardElement
    var parent: BaseContainer?
    let insertionIndex: Int
    
    func restore() {
        parent?.insert(element,
                       at: insertionIndex)
    }
    
    func restore(undoManager: UndoManager?) {
        restore()
        
        // TODO: What to do here?
//        undoManager?.registerUndo(withTarget: self, handler: { selfRef in
//            selfRef.element.removeFromParent(undoManager: undoManager)
//        })
    }
}

extension Artboard {
    
    public func remove(
        _ model: any ArtboardElement
    ) -> InsertionContext? {
        if let _ = model.parent {
            return model.removeFromParent()
        } else if let insertionIndex = elements.remove(model) {
                return InsertionContext(element: model, parent: nil, insertionIndex: insertionIndex)
        } else {
            return nil
        }
    }
}

extension ArtboardElement {
    fileprivate func removeFromParent() -> InsertionContext? {
        let parent = parent
        guard let insertionIndex = parent?.remove(self)
        else { return nil }

        return InsertionContext(element: self,
                                parent: parent,
                                insertionIndex: insertionIndex)
    }
    
    @discardableResult
    fileprivate func removeFromParent(undoManager: UndoManager?) -> InsertionContext? {
        guard let insertionContext = removeFromParent() else {
            return nil
        }
        
        undoManager?.registerUndo(withTarget: self, handler: { selfRef in

            insertionContext.restore(undoManager: undoManager)
        })
        
        return insertionContext
    }
}
