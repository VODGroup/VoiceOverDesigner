import Foundation
import Combine

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
    private(set) var controls: [any AccessibilityView] {
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
    
    public func append(control: any AccessibilityView) {
        let frameThatOverlaps = document.artboard.frames.first { frame in
            frame.frame.intersects(control.frame)
        }
        
        if let frameThatOverlaps {
            frameThatOverlaps.elements.append(control)
        } else {
            document.artboard.controlsWithoutFrames.append(control)
        }
    }
    
    open func remove(_ model: any AccessibilityView) {
        switch model.cast {
        case .frame(let frame):
            // TODO: Remove model
            fatalError()
            break
        case .element(let element):
            if let topLevelIndex = controls.delete(element) {
                document.undo?.registerUndo(withTarget: self, handler: { presenter in
                    presenter.insert(model: element, at: topLevelIndex)
                })
            } else {
                guard let container = controls.container(for: element),
                      let containerIndex = container.elements.remove(element)
                else { return }
                
                document.undo?.registerUndo(withTarget: self, handler: { presenter in
                    presenter.insert(element, into: container, at: containerIndex)
                })
            }
            
        case .container(let container):
            if let topLevelIndex = controls.delete(container) {
                document.undo?.registerUndo(withTarget: self, handler: { presenter in
                    presenter.insert(model: container, at: topLevelIndex)
                })
            }
        }
        
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
        model: any AccessibilityView,
        at instertionIndex: Int
    ) {
        controls.insert(model, at: instertionIndex)
        publishControlChanges()
    }
    
    @discardableResult
    public func wrapInContainer(
        _ elements: [any AccessibilityView]
    ) -> A11yContainer? {
        controls.wrapInContainer(
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
    
    public var firstFrameControls: [any AccessibilityView] {
        document.artboard.frames.first?.elements ?? []
    }
    
    public var controlsWithoutFrame: [any AccessibilityView] {
        document.artboard.controlsWithoutFrames
    }
}
#endif
