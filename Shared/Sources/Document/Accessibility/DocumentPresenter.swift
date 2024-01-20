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
    
    // MARK: - Controls update
    public let artboardPublisher: PassthroughSubject<Artboard, Never> = .init()
    
    /// Controls should be changed only from this presenter to support undoing
    public private(set) var elements: [any ArtboardElement] {
        set {
            let oldValue = document.artboard.elements
            
            document.artboard.replace(newValue)
            
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
    open func add(
        image: Image,
        name: String?,
        origin: CGPoint
    ) {
        document.invalidateQuickViewPreview()
        
        let frame = Frame(image: image,
                          name: name,
                          frame: CGRect(origin: origin,
                                        size: image.size))
        
        add(frame,
            into: document.artboard,
            at: document.artboard.frames.count)
    }
    
    open func importArtboard(
        _ importingDocument: VODesignDocument
    ) {
        importingDocument.artboard.offsetCoordinates(toFit: self.document.artboard)
        
        // TODO: Force unwrap if OK?
        let imageLoader = importingDocument.artboard.imageLoader!
        
        let currentDocumentPath = (self.document as! VODesignDocument).fileURL
        
        for frame in importingDocument.artboard.frames {
            add(frame,
                into: importingDocument.artboard,
                at: importingDocument.artboard.frames.count)
        }
        
        // TODO: Copy images
        // TODO: Rename images if needed
        // TODO: Undo images copying, frames insertion
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
        // Undo action is called in reverse order
        document.undo?.registerUndo(
            withTarget: self,
            handler: { presenter in
                presenter.publishArtboardChanges()
                presenter.select(model)
            })

        model.removeFromParent(undoManager: document.undo)
        
        publishArtboardChanges()
        deselect()
    }
    
    private func add(
        _ model: any ArtboardElement,
        into parent: BaseContainer,
        at insertionIndex: Int
    ) {
        document.artboard.insert(model, at: insertionIndex)
        
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
        document.undo?.registerUndo(withTarget: self, handler: { presenter in
            presenter.publishArtboardChanges() // Some changes will happen after undo
        })
        
        let container = document.artboard.wrapInContainer(
            elements,
            dropElement: nil,
            undoManager: document.undo)
        
        publishArtboardChanges()
        
        return container
    }
    
    public func unwrapContainer(_ container: A11yContainer) {
        document.artboard.unwrapContainer(container)
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
        // Update document after undoing on model layer
        document.undo?.registerUndo(withTarget: self, handler: { presenter in
            presenter.publishArtboardChanges() // Some changes will happen after undo
        })
        
        let didDrag = document.artboard
            .drag(draggingElement,
                  over: dropElement,
                  insertionIndex: insertAtIndex,
                  undoManager: document.undo)
        
        if didDrag {
            publishArtboardChanges() // Some changes happened
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
