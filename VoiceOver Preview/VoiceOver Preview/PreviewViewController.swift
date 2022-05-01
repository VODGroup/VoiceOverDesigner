//
//  PreviewViewController.swift
//  VoiceOver Preview
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import UIKit
import Document

final class PreviewViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            self.document.controls.forEach(self.drawingService.drawControl(from:))
            self.view().layout = VoiceOverLayout(controls: self.document.controls, container: self.view)
        }
    }
}

class PreviewView: UIView {
    var layout: VoiceOverLayout? {
        didSet {
            accessibilityElements = layout?.accessibilityElements
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
        let element = UIAccessibilityElement(accessibilityContainer: container)
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
}
