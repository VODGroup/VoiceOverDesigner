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
        let storyboard = UIStoryboard(name: "VODesignPreviewViewController",
                                      bundle: Bundle.module)
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
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc
    func documentStateChanged(_ notification: Notification) {
        document.printState()
        
        if document.documentState == .progressAvailable {
            loadAndDraw()
        }
    }
    
    func view() -> VODesignPreviewView {
        view as! VODesignPreviewView
    }
    
    private func loadAndDraw() {
        self.view().canvas.removeAll()
        document.close()
        
        document.open { isSuccess in
            if isSuccess {
                self.draw(document: self.document)
            } else {
                fatalError() // TODO: Present something to user
            }
        }
    }
    
    private func draw(document: VODesignDocument) {
        view().image = document.image
        view().controls = document.controls
    }
}
