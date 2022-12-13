import Foundation
import UIKit
import Document
import Canvas

class VODesignPreviewView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundImageHeight: NSLayoutConstraint!
    @IBOutlet weak var canvas: Canvas!
   
    func setup(
        image: UIImage?,
        controls: [any AccessibilityView]
    ) {
        self.image = image
        self.controls = controls
        
        scrollView.delegate = self
    }
    
    var image: UIImage? {
        didSet {
            backgroundImageView.image = image
            
            guard let image = image else { return }
            
            guard image.size.width != 0 else { return }
            let aspectRatio = bounds.width / image.size.width
            backgroundImageHeight.constant = image.size.height * aspectRatio
            
            let scale = frame.width / image.size.width
            canvas.scale = scale
        }
    }
    
    
    private var controls: [any AccessibilityView] = [] {
        didSet {
            
            drawingController.drawControls(
                controls,
                scale: canvas.scale)
            
            updateVoiceOverLayoutForCanvas()
        }
    }
    
        private lazy var drawingController = DrawingController(view: canvas)
}

extension VODesignPreviewView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateVoiceOverLayoutForCanvas()
    }
    
    private func updateVoiceOverLayoutForCanvas() {
        let offset = scrollView.frame.minY - scrollView.bounds.minY
        
        canvas.layout = VoiceOverLayout(
            controls: controls,
            container: canvas,
            yOffset: offset)
    }
}
