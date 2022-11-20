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
    
    public static func controller(presenter: CanvasPresenter) -> UIViewController {
        let storyboard = UIStoryboard(name: "VODesignPreviewViewController",
                                      bundle: .module)
        let preview = storyboard
            .instantiateInitialViewController() as! VODesignPreviewViewController
        
        preview.presenter = presenter
        
        return preview
    }
    
    var presenter: CanvasPresenter!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        draw()
        
        addGestures() // TODO: If document would drawn several times gestures will be added a lot
    }
    
    func view() -> VODesignPreviewView {
        view as! VODesignPreviewView
    }
}

// MARK: - Loading
extension VODesignPreviewViewController {
    
    private func draw() {
        self.view().canvas.removeAll() // TODO: Move clearing inside? drawingController?
        
        presenter.didLoad(
            ui: view().canvas,
            screenUI: view())
        
        view().image = presenter.document.image
    }
}

// MARK: - Gesture
extension VODesignPreviewViewController {
    func addGestures() {
        let pencilDrawingGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(didPan(gesture:)))
        pencilDrawingGesture.allowedTouchTypes = [
            NSNumber(value: UITouch.TouchType.pencil.rawValue)
            // Should we disable pencil touches for scrollView?
            // See also https://www.swiftbysundell.com/articles/building-ipad-pro-features-in-swift/
        ]
        view().canvas.addGestureRecognizer(pencilDrawingGesture)
        
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
