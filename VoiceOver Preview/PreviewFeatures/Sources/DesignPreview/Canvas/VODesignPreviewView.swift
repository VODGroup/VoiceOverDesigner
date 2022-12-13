import Foundation
import UIKit
import Document
import Canvas

class VODesignPreviewView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundImageHeight: NSLayoutConstraint!
    @IBOutlet weak var canvas: Canvas!
   
    var image: UIImage? {
        didSet {
            backgroundImageView.image = image
            
            guard let image = image else { return }
            
            guard image.size.height != 0 else { return }
            let aspectRatio = bounds.height / image.size.height
            backgroundImageHeight.constant = image.size.height * aspectRatio
            
            
            let scale = frame.height / image.size.height
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
