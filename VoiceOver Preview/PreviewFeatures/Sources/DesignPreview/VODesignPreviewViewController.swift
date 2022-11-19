//
//  PreviewViewController.swift
//  VoiceOver Preview
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import UIKit
import Document
import Canvas

public final class VODesignPreviewViewController: UIViewController {
    
    public static func controller(for document: VODesignDocument) -> UIViewController {
        let storyboard = UIStoryboard(name: "VODesignPreviewViewController",
                                      bundle: .module)
        let preview = storyboard.instantiateInitialViewController() as! VODesignPreviewViewController
        preview.open(document: document) // TODO: load document firstly, then load controller
        return preview
    }
    
    private var presenter: CanvasPresenter!
    
    private var document: VODesignDocument!
    func open(document: VODesignDocument) {
        self.document = document
        self.presenter = CanvasPresenter(document: document)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAndDraw()
        addDocumentStateObserving()

    }
    
    func view() -> VODesignPreviewView {
        view as! VODesignPreviewView
    }
}

// MARK: - Loading
extension VODesignPreviewViewController {
    
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
        presenter.didLoad(
            ui: view().canvas,
            screenUI: view())
        
        view().image = presenter.document.image
        
        addGestures() // TODO: If document would drawn several times gestures will be added a lot
    }
}

// MARK: - Gesture
extension VODesignPreviewViewController {
    func addGestures() {
        let drawingGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(didPan(gesture:)))
        view().canvas.addGestureRecognizer(drawingGesture)
        
        let selectionGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTap(gesture:)))
        view().canvas.addGestureRecognizer(selectionGesture)
    }
    
    @objc func didTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        
        switch gesture.state {
        case .began:
            break
        case .changed:
            break
        case .ended:
            presenter.mouseDown(on: location)
            presenter.mouseUp(on: location)
        case .cancelled: break
        case .failed: break
        case .possible: break
        @unknown default:
            break
        }
    }
    
    @objc func didPan(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        
        switch gesture.state {
        case .began:
            presenter.mouseDown(on: location)
        case .changed:
            presenter.mouseDragged(on: location)
        case .ended:
            presenter.mouseUp(on: location)
        case .cancelled: break
        case .failed: break
        case .possible: break
        @unknown default:
            break
        }
    }
}

// MARK: - iCloud sync
extension VODesignPreviewViewController {
    private func addDocumentStateObserving() {
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
}
