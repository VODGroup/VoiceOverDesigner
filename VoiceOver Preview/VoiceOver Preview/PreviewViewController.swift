//
//  PreviewViewController.swift
//  VoiceOver Preview
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import UIKit
import Document

final class PreviewViewController: UIViewController {
    
    lazy var documentBrowser: UIDocumentBrowserViewController = {
        let controller = UIDocumentBrowserViewController()
        controller.allowsPickingMultipleItems = false
        controller.allowsDocumentCreation = false
      return controller
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        documentBrowser.delegate = self
        loadAndDraw()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(Self.documentStateChanged(_:)),
            name: UIDocument.stateChangedNotification, object: document)
    }
    
    @objc
    func documentStateChanged(_ notification: Notification) {
        document.printState()
        
        if document.documentState == .progressAvailable {
            loadAndDraw()
        }
    }
    
    private lazy var drawingService = DrawingService(view: view)
    
    private lazy var document: VODesignDocument = {
        #if targetEnvironment(simulator)
        let url = Bundle.main.url(forResource: "controls",
                                  withExtension: "json")!
        return VODesignDocument(fileURL: url.deletingLastPathComponent())
        #else
        // Device
        return VODesignDocument(fileName: "Test")
        #endif
    }()
    
    func view() -> PreviewView {
        view as! PreviewView
    }
    
    private func loadAndDraw() {
        self.drawingService.removeAll()
        document.close()
        
        document.open { isSuccess in
            if isSuccess {
                self.document.controls.forEach(self.drawingService.drawControl(from:))
                self.view().layout = VoiceOverLayout(controls: self.document.controls, container: self.view)
            } else {
                self.present(self.documentBrowser, animated: true)
            }
            
        }
    }
}

class PreviewView: UIView {
    var layout: VoiceOverLayout? {
        didSet {
            accessibilityElements = layout?.accessibilityElements
        }
    }
    
    override func accessibilityIncrement() {
        super.accessibilityIncrement()
        layout?.focusedElement?.accessibilityIncrement()
    }
    
    override func accessibilityDecrement() {
        super.accessibilityDecrement()
        layout?.focusedElement?.accessibilityDecrement()
    }
    
    
}

extension PreviewViewController: UIDocumentBrowserViewControllerDelegate {
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        if let url = documentURLs.first {
            let document = VODesignDocument(fileURL: url)
            self.document = document
            loadAndDraw()
            documentBrowser.dismiss(animated: true)
        }
    }
    
    
}

class VoiceOverLayout {
    private let controls: [A11yDescription]
    private let container: UIView
    
    init(controls: [A11yDescription], container: UIView) {
        self.controls = controls
        self.container = container
    }
    
    private func accessibilityElement(from control: A11yDescription) -> UIAccessibilityElement {
        let element = VoiceOverElement(accessibilityContainer: container)
        element.control = control
        element.isAccessibilityElement = true
        element.accessibilityLabel = control.label
        element.accessibilityValue = control.value
        element.accessibilityHint = control.hint
        element.accessibilityFrame = control.frame
        element.accessibilityTraits = control.trait.accessibilityTrait
        
        return element
    }
    
    var accessibilityElements: [UIAccessibilityElement] {
        controls.map(accessibilityElement(from:))
    }
    
    /// A11y element that currently focused by VoiceOver
    var focusedElement: UIAccessibilityElement? {
        accessibilityElements.first(where: {$0.accessibilityElementIsFocused()})
    }
    
}


