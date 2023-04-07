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
