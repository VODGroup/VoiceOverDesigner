import AppKit

class ContentView: FlippedView {
    
    var imageViews: [NSImageView] = []
    
    func add(image: NSImage) {
        let imageView = NSImageView()
        imageView.image = image
        imageView.sizeToFit()
        imageView.frame = CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: image.size)
        addSubview(imageView)
        imageViews.append(imageView)
    }
    
    override var intrinsicContentSize: NSSize {
        return imageViews
            .reduce(CGRect.zero) { partialResult, imageView in
                partialResult.union(imageView.frame)
            }
            .size
    }
    
    var image: NSImage? {
        imageViews.first?.image
    }
}
