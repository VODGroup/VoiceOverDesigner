import Foundation
import UIKit
import Document
import VoiceOverLayout
import Canvas

class VODesignPreviewView: UIView {
    @IBOutlet weak var backgroundImageView: ScaledImageView!
    @IBOutlet weak var canvas: Canvas!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        translatesAutoresizingMaskIntoConstraints = false // Forward to use intrinsicContentSize
    }
    var image: UIImage? {
        didSet {
            backgroundImageView.image = image
        }
    }
    
    
    var controls: [any AccessibilityView] = [] {
        didSet {
            // TODO: Is it correct to path 0?
            updateAccessilibityLayout(yOffset: 0)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            backgroundImageView.intrinsicContentSize
        }
        
        set {}
    }
    
    func updateAccessilibityLayout(yOffset: CGFloat) {
        canvas.layout = VoiceOverLayout(
            controls: controls,
            container: canvas,
            yOffset: yOffset)
    }
}

class ScaledImageView: UIImageView {
    var scale: CGFloat = 3
    
    override var intrinsicContentSize: CGSize {
        get {
            return image?.size.inverted(scale: scale) ?? .zero
        }
        
        set {}
    }
}
