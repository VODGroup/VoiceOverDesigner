import Foundation
import Artboard

private let NSOutlineViewDropOnItemIndex = -1

extension Artboard {
    
    enum DragType {
        case wrapInContainer(secondElement: A11yDescription)
        case moveInsideContainer(container: any ArtboardContainer, insertionIndex: Int)
        case appendToContainer(container: any ArtboardContainer)
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
                
            case (let container as any ArtboardContainer, NSOutlineViewDropOnItemIndex):
                return .appendToContainer(container: container)
                
            case (let container as any ArtboardContainer, insertionIndex):
                return .moveInsideContainer(container: container, insertionIndex: insertionIndex)
                
            case (nil, NSOutlineViewDropOnItemIndex):
                return .moveOnArtboardLevel(insertionIndex: elements.count) // Append
                
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
        
        print("Perforem drag operation \(dragType)")
        switch dragType {
        case .wrapInContainer(let dropElement):
            wrapInContainer(
                [draggingElement, dropElement],
                dropElement: dropElement,
                undoManager: undoManager)
            
        case .moveInsideContainer(let container, let insertionIndex):
            move(draggingElement,
                 inside: container,
                 insertionIndex: insertionIndex,
                 undoManager: undoManager)
        
        case .appendToContainer(let container):
            move(draggingElement,
                 inside: container,
                 insertionIndex: container.elements.count, // Append
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
            _ = element.removeFromParent()
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
        dropElement: (any ArtboardElement)?,
        undoManager: UndoManager?
    ) -> A11yContainer {
        let elements = sorted(elements)
        let dropElement = dropElement ?? elements.first!
        
        let parent = dropElement.parent
        
        /// Place container on the place of first element
        var insertionIndex: Int?
        
        var insertionContexts = [InsertionContext]()
        for element in elements
        {
            // Item before drop element can be removed, that's why we remember instert position during removing
            if element === dropElement {
                insertionIndex = dropElement.parent?.elements.firstIndex(where: { control in
                    control === dropElement
                })
            }
            insertionContexts.append(element.removeFromParent()!)
        }

        let container = A11yContainer(
            elements: elements,
            frame: elements
                .map(\.frame)
                .commonFrame
                .insetBy(dx: -20, dy: -20),
            label: "Container")
        
        let isValidInsertion = insertionIndex! <= (parent ?? self).elements.count 
        if isValidInsertion {
            (parent ?? self).insert(container, // <-- Insert container
                                    at: insertionIndex!)
        } else {
            (parent ?? self).append(container)
        }
        
        removeEmptyContainers()
        
        undoManager?.registerUndo(withTarget: self, handler: { artboard in
            _ = container.removeFromParent()

            for insertionContext in insertionContexts.reversed() {
                insertionContext.restore()
            }
            
            undoManager?.registerUndo(withTarget: artboard, handler: { artboard in
                artboard.wrapInContainer(elements, dropElement: dropElement, undoManager: undoManager)
            })
        })
        
        return container
    }
    
    func sorted(_ elements: [any ArtboardElement]) -> [any ArtboardElement] {
        let flattenElement = self.elements.flattenElements()
        
        return elements.sorted { lhs, rhs in
            flattenElement.firstIndex { $0 === lhs }!
            <
            flattenElement.firstIndex { $0 === rhs }!
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
        
        undoManager?.registerUndo(withTarget: self, handler: { selfRef in
            selfRef.element.removeFromParent(undoManager: undoManager)
        })
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
    public func removeFromParent(undoManager: UndoManager?) -> InsertionContext? {
        guard let insertionContext = removeFromParent() else {
            return nil
        }
        
        undoManager?.registerUndo(withTarget: self, handler: { selfRef in

            insertionContext.restore(undoManager: undoManager)
        })
        
        return insertionContext
    }
}
