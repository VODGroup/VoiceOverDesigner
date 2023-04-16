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
    
    
    var controls: [any ArtboardElement] = [] 
    
    override var intrinsicContentSize: CGSize {
        get {
            backgroundImageView.intrinsicContentSize
        }
        
        set {}
    }
}

extension VODesignPreviewView: PreviewSourceProtocol {
    func previewImage() -> Image? {
        canvas.drawHierarchyAsImage() // TODO: Test it
    }
}

extension UIView {
    public func drawHierarchyAsImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        return image
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
