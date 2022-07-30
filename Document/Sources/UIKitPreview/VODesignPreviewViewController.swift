//
//  PreviewViewController.swift
//  VoiceOver Preview
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import UIKit
import Document

public final class VODesignPreviewViewController: UIViewController {
    
    public static func controller(for document: VODesignDocument) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.module)
        let preview = storyboard.instantiateInitialViewController() as! VODesignPreviewViewController
        preview.open(document: document)
        return preview
    }
    
    private var document: VODesignDocument!
    func open(document: VODesignDocument) {
        self.document = document
    }

    public override func viewDidLoad() {
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
    
    private lazy var drawingController = DrawingController(view: view())
    
    public override func loadView() {
        view = VODesignPreviewView(frame: .zero)
    }
    
    func view() -> VODesignPreviewView {
        view as! VODesignPreviewView
    }
    
    private func loadAndDraw() {
        self.view().removeAll()
        document.close()
        
        document.open { isSuccess in
            if isSuccess {
                for control in self.document.controls {
                    self.drawingController.drawControl(from: control)
                }
                
                self.view().layout = VoiceOverLayout(controls: self.document.controls, container: self.view)
                self.view().imageView.image = self.document.image
            } else {
                fatalError() // TODO: Present something to user
            }
            
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
        VoiceOverElement(control: control, accessibilityContainer: container) 
    }
    
    var accessibilityElements: [UIAccessibilityElement] {
        controls.map(accessibilityElement(from:))
    }
}


