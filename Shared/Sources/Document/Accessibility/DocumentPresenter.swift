import Foundation
import Combine
import Artboard

public typealias OptionalDescriptionSubject = CurrentValueSubject<(any ArtboardElement)?, Never>

/**
 Top level object that controls abstract VODesignDocumentProtocol and publish changes

 Responsibility:
 - Publish updates after any changes on control's level to initiate UI update of any ViewController
 - Undo changes on controls level
 */
open class DocumentPresenter {
    
    public init(document: VODesignDocumentProtocol) {
        self.document = document
    }
    public private(set) var document: VODesignDocumentProtocol
    
    // MARK: - Contols update
    public let artboardPublisher: PassthroughSubject<Artboard, Never> = .init()
    
    /// Controls should be changed only from this presenter to support undoing
    public private(set) var elements: [any ArtboardElement] {
        set {
            let oldValue = document.artboard.elements
            
            document.artboard.elements = newValue
            
            document.undo?.registerUndo(withTarget: self, handler: { presenter in
                presenter.elements = oldValue
            })
            
            publishArtboardChanges()
        }
        
        get {
            document.artboard.elements
        }
    }
    
    public func publishArtboardChanges() {
        artboardPublisher.send(document.artboard)
    }
    
    public let selectedPublisher = OptionalDescriptionSubject(nil)
    
    public func select(_ element: (any ArtboardElement)?) {
        selectedPublisher.send(element)
    }
    
    public func deselect() {
        selectedPublisher.send(nil)
    }
    
    // MARK:
    open func add(image: Image, origin: CGPoint) {
        document.invalidateQuickViewPreview()
        
        let frame = Frame(image: image,
                          frame: CGRect(origin: origin,
                                        size: image.size))
        
        add(frame,
            into: document.artboard,
            at: document.artboard.frames.count)
    }
    
    public func append(control: any ArtboardElement) {
        let frameThatOverlaps = document.artboard.frames.first { frame in
            frame.frame.intersects(control.frame)
        }
        
        if let frameThatOverlaps {
            frameThatOverlaps.append(control)
        } else {
            document.artboard.append(control)
        }
        
        document.undo?.registerUndo(
            withTarget: self,
            handler: { presenter in
                presenter.remove(control)
        })
        publishArtboardChanges()
    }
    
    open func remove(_ model: any ArtboardElement) {
        guard let insertionContext: InsertionContext = document.artboard.remove(model)
        else { return }

        publishArtboardChanges()
        deselect()
        
        document.undo?.registerUndo(
            withTarget: self,
            handler: { presenter in
                // TODO: use restore of InsertionContext
                presenter.add(model,
                              into: insertionContext.parent!,
                              at: insertionContext.insertionIndex)
        })
    }
    
    private func add(
        _ model: any ArtboardElement,
        into parent: BaseContainer,
        at insertionIndex: Int
    ) {
        parent.insert(model, at: insertionIndex)
        
        publishArtboardChanges()
        select(model)
        
        document.undo?.registerUndo(
            withTarget: self,
            handler: { presenter in
                presenter.remove(model)
            })
    }
    
    @discardableResult
    public func wrapInContainer(
        _ elements: [any ArtboardElement]
    ) -> A11yContainer? {
        
        let container = document.artboard.wrapInContainer(
            elements,
            undoManager: document.undo)
        
        publishArtboardChanges()
        
        return container
    }
    
    public func unwrapContainer(_ container: A11yContainer) {
        elements.unwrapContainer(container)
    }
    
    public func canDrag(
        _ draggingElement: any ArtboardElement,
        over dropElement: (any ArtboardElement)?,
        insertionIndex: Int
    ) -> Bool {
        document.artboard.canDrag(draggingElement,
                                  over: dropElement,
                                  insertionIndex: insertionIndex)
    }
    
    public func drag(
        _ draggingElement: any ArtboardElement,
        over dropElement: (any ArtboardElement)?,
        insertAtIndex: Int
    ) -> Bool {
        
        let didDrag = document.artboard
            .drag(draggingElement,
                  over: dropElement,
                  insertionIndex: insertAtIndex,
                  undoManager: document.undo)
        
        if didDrag {
            publishArtboardChanges() // Some changes happened
            document.undo?.registerUndo(withTarget: self, handler: { presenter in
                presenter.publishArtboardChanges() // Some changes will happen after undo
            })
        }
        
        return didDrag
    }
}

#if canImport(XCTest)
extension DocumentPresenter {
    public func replace(elements: [A11yDescription]) {
        self.elements = elements
    }
    
    public var firstFrameControls: [any ArtboardElement] {
        document.artboard.frames.first?.elements ?? []
    }
}
#endif
