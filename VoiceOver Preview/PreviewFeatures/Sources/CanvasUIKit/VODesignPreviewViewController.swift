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
        
#if DEBUG
        addGestures()
#endif
    }
    
    func view() -> VODesignPreviewView {
        view as! VODesignPreviewView
    }
}

// MARK: - Loading
extension VODesignPreviewViewController {
    
    private func draw() {
        self.view().canvas.removeAll() // TODO: Move clearing inside? drawingController?
        
        view().set(image: presenter.document.artboard.frames.first?.image, // TODO: Support several frames
                   scale: presenter.document.frameInfo.imageScale)
        view().controls = presenter.document.controls
        presenter.didLoad(
            uiContent: view().canvas,
            uiScroll: self,
            initialScale: 1,
            previewSource: view())
    }
}

// MARK: - Gesture
extension VODesignPreviewViewController {
    func addGestures() {
        let pencilDrawingGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(didPan(gesture:)))
        // It is impossible to recognize Apple Pencil touches in sumulator
        #if targetEnvironment(simulator)
        pencilDrawingGesture.allowedPressTypes = [NSNumber(value: UITouch.TouchType.direct.rawValue)]
        #else
        pencilDrawingGesture.allowedTouchTypes = [
            

            NSNumber(value: UITouch.TouchType.pencil.rawValue)
            
            // Should we disable pencil touches for scrollView?
            // See also https://www.swiftbysundell.com/articles/building-ipad-pro-features-in-swift/
        ]
        #endif
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

extension VODesignPreviewViewController: CanvasScrollViewProtocol {
    public func fitToWindow(animated: Bool) {
        // TODO: Do we need something here?
    }
}
