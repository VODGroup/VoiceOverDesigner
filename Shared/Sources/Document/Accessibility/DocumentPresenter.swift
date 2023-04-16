import Foundation
import Combine
import Artboard

public typealias OptionalDescriptionSubject = CurrentValueSubject<(any ArtboardElement)?, Never>

/**
 Top level object that controls abstract VODesignDocumentProtocol
 
 Allowh to publishControlChanges after any changes on controls level to initiate UI update of any ViewController
 Also manages undo changes on controls level
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
            
            artboardPublisher.send(document.artboard)
        }
        
        get {
            document.controls
        }
    }
    
    public func publishControlChanges() {
        artboardPublisher.send(document.artboard)
    }
    
    public let selectedPublisher = OptionalDescriptionSubject(nil)
    
    // MARK:
    public func update(image: Image) {
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
        
        publishControlChanges()
    }
    
    open func remove(_ model: any ArtboardElement) {
        guard let (parent, index) = document.artboard.remove(model)
        else { return }
        
        document.undo?.registerUndo(withTarget: self, handler: { presenter in
//            presenter.insert(model, into: parent, at: index)
        })
        
        publishControlChanges()
    }
    
    private func insert(
        _ model: A11yDescription,
        into container: A11yContainer,
        at instertionIndex: Int
    ) {
        container.elements.insert(model, at: instertionIndex)
        publishControlChanges()
    }
    
    private func insert(
        model: any ArtboardElement,
        at instertionIndex: Int
    ) {
        controls.insert(model, at: instertionIndex)
        publishControlChanges()
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
        self.document.artboard.controlsWithoutFrames = elements
    }
    
    public var firstFrameControls: [any ArtboardElement] {
        document.artboard.frames.first?.elements ?? []
    }
    
    public var controlsWithoutFrame: [any ArtboardElement] {
        document.artboard.controlsWithoutFrames
    }
}
#endif
