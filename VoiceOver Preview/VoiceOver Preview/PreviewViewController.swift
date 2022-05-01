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
    }
    
    private lazy var drawingService = DrawingService(view: view)
    private lazy var document: VODesignDocument = {
        let url = Bundle.main.url(forResource: "controls",
                                  withExtension: "json")!
        return VODesignDocument(fileURL: url.deletingLastPathComponent())
    }()
    
    func view() -> PreviewView {
        view as! PreviewView
    }
    
    private func loadAndDraw() {
        do {
            try document.read()
            document.controls.forEach(drawingService.drawControl(from:))
            view().layout = VoiceOverLayout(controls: document.controls, container: view)
        } catch let error {
            print(error)
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
