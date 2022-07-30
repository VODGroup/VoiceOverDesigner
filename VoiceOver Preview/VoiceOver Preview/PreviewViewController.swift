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
    
    private lazy var drawingController = DrawingController(view: view())
    
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
    
    override func loadView() {
        view = PreviewView(frame: .zero)
    }
    
    func view() -> PreviewView {
        view as! PreviewView
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
                self.present(self.documentBrowser, animated: true)
            }
            
        }
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
        VoiceOverElement(control: control, accessibilityContainer: container) 
    }
    
    var accessibilityElements: [UIAccessibilityElement] {
        controls.map(accessibilityElement(from:))
    }
    
}


