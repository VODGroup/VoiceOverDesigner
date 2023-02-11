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
    
    func set(image: Image?, scale: CGFloat) {
        backgroundImageView.image = image
        backgroundImageView.scale = scale
    }
    
    
    var controls: [any AccessibilityView] = [] 
    
    override var intrinsicContentSize: CGSize {
        get {
            backgroundImageView.intrinsicContentSize
        }
        
        set {}
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
