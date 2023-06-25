import Foundation
import Combine
import Artboard

public typealias OptionalDescriptionSubject = CurrentValueSubject<(any ArtboardElement)?, Never>

/**
 Top level object that controls abstract VODesignDocumentProtocol
 
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
    
    /// Conrols should be changed only from this presenter to suppont undoing
    @available(*, deprecated, message: "Use `artboard`")
    private(set) var controls: [any ArtboardElement] {
        set {
            let oldValue = document.controls
            
            document.controls = newValue
            Swift.print("Set controls: \(controls.map(\.label))")
            
            document.undo?.registerUndo(withTarget: self, handler: { presenter in
                presenter.controls = oldValue
            })
            
            publishControlChanges()
        }
        
        get {
            document.controls
        }
    }
    
    public func publishControlChanges() {
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
    open func add(image: Image) {
        document.addFrame(with: image)
    }
    
    public func append(control: any ArtboardElement) {
        let frameThatOverlaps = document.artboard.frames.first { frame in
            frame.frame.intersects(control.frame)
        }
        
        if let frameThatOverlaps {
            control.parent = frameThatOverlaps
            frameThatOverlaps.elements.append(control)
        } else {
            document.artboard.controlsWithoutFrames.append(control)
        }
        
        document.undo?.registerUndo(
            withTarget: self,
            handler: { presenter in
                presenter.remove(control)
        })
        publishControlChanges()
    }
    
    open func remove(_ model: any ArtboardElement) {
        guard let (parent, insertionIndex) = document.artboard.remove(model)
        else { return }

        publishControlChanges()
        deselect()
        
        document.undo?.registerUndo(
            withTarget: self,
            handler: { presenter in
                presenter.restore(model,
                                  into: parent,
                                  at: insertionIndex)
        })
    }
    
    private func restore(
        _ model: any ArtboardElement,
        into parent: (any ArtboardContainer)?,
        at insertionIndex: Int
    ) {
        if let parent {
            parent.elements.insert(model, at: insertionIndex)
        } else {
            document.artboard.controlsWithoutFrames.insert(model, at: insertionIndex)
        }
        
        publishControlChanges()
        select(model)
    }
    
    @discardableResult
    public func wrapInContainer(
        _ elements: [any ArtboardElement]
    ) -> A11yContainer? {
        controls.wrap(
            in: A11yContainer.self,
            elements.extractElements(),
            label: "Container")
    }
    
    public func unwrapContainer(_ container: A11yContainer) {
        controls.unwrapContainer(container)
    }
}

#if canImport(XCTest)
extension DocumentPresenter {
    public func update(elements: [A11yDescription]) {
        self.controls = elements
    }
    
    public var firstFrameControls: [any ArtboardElement] {
        document.artboard.frames.first?.elements ?? []
    }
    
    public var controlsWithoutFrame: [any ArtboardElement] {
        document.artboard.controlsWithoutFrames
    }
}
#endif
