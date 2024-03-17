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
    @discardableResult
    open func add(
        image: Image,
        name: String?,
        origin: CGPoint
    ) -> Frame {
        document.invalidateQuickViewPreview()
        let imageLocation = document.addImageWrapper(image: image, name: name)
        let frame = Frame(imageLocation: imageLocation,
                          name: name,
                          frame: CGRect(origin: origin,
                                        size: image.size))
        
        add(frame,
            into: document.artboard,
            at: document.artboard.frames.count)
        
        return frame
    }
    
    open func importArtboard(
        _ importingDocument: VODesignDocument
    ) {
        importingDocument.artboard.offsetCoordinates(toFit: self.document.artboard)
        
        for frame in importingDocument.artboard.frames {
            add(frame,
                into: importingDocument.artboard,
                at: self.document.artboard.frames.count,
                publishChanges: false) // Will be called after last frame
            
            copyImage(for: frame,
                      from: importingDocument,
                      to: self.document)
        }
        
        publishArtboardChanges()
    }
    
    private func copyImage(
        for frame: Frame,
        from oldDocument: ImageLoading?,
        to newDocument: VODesignDocumentProtocol
    ) {
        let newName = UUID().uuidString
        
        if let image = oldDocument?.image(for: frame) {
            newDocument.addImageWrapper(image: image, name: newName)
            frame.imageLocation = .fileWrapper(name: newName)
        }
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
        at insertionIndex: Int,
        publishChanges: Bool = true
    ) {
        document.artboard.insert(model, at: insertionIndex)
        
        if publishChanges {
            publishArtboardChanges()
        }
        
        select(model)
        
        document.undo?.registerUndo(
            withTarget: self,
            handler: { presenter in
                presenter.remove(model)
            })
    }
    
    @discardableResult
    open func wrapInContainer(
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
    
#if canImport(XCTest)
    open func replace(elements: [A11yDescription]) {
        self.elements = elements
    }
    
    public var firstFrameControls: [any ArtboardElement] {
        document.artboard.frames.first?.elements ?? []
    }
#endif
}
