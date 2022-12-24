import Foundation
import UIKit
import Document
import VoiceOverLayout
import Canvas

class VODesignPreviewView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var canvas: Canvas!
   
    var image: UIImage? {
        didSet {
            backgroundImageView.image = image
        }
    }
    
    
    var controls: [any AccessibilityView] = [] {
        didSet {
            updateVoiceOverLayoutForCanvas()
        }
    }
    


}

extension VODesignPreviewView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateVoiceOverLayoutForCanvas()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        container
    }
    
    private func updateVoiceOverLayoutForCanvas() {
        let offset = scrollView.frame.minY - scrollView.bounds.minY
        
        canvas.layout = VoiceOverLayout(
            controls: controls,
            container: canvas,
            yOffset: offset)
    }
}
