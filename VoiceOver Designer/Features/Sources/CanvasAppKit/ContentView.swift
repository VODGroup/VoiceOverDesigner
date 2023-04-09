import AppKit

class ContentView: FlippedView {
    
    var imageViews: [NSImageView] = []
    
    func add(_ image: NSImage, at frame: CGRect) {
        let imageView = NSImageView()
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = frame
        addSubview(imageView)
        imageViews.append(imageView)
    }
    
    override var intrinsicContentSize: NSSize {
        boundingBox.size
    }
    
    private var boundingBox: CGRect {
        imageViews
            .reduce(CGRect.zero) { partialResult, imageView in
                partialResult.union(imageView.frame)
            }
    }
    
    var image: NSImage? {
        imageViews.first?.image
    }
    
    func image(at frame: CGRect) -> CGImage? {
        let imageView = imageViews.first { imageView in
            imageView.frame.intersects(frame)
        }
        
        guard let image = imageView?.image,
              let imageViewFrame = imageView?.frame
        else { return nil }
        
        var frameInImageCoordinates = frame
            .scaled(image.recommendedLayerContentsScale(1))
            .origin(to: imageViewFrame)
        
        let cgImage = image
            .cgImage(forProposedRect: &frameInImageCoordinates,
                     context: nil,
                     hints: nil)?
            .cropping(to: frameInImageCoordinates)
        
        return cgImage
    }
}

extension CGRect {
    func origin(to parentFrame: CGRect) -> CGRect {
        CGRect(origin: CGPoint(x: origin.x - parentFrame.origin.x,
                               y: origin.y - parentFrame.origin.y),
               size: size)
    }
}
