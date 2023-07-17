import AppKit

import CommonUI
import Document
import Canvas

class ContentView: FlippedView, DrawingView {
    var frames: [Canvas.ImageLayer] = []
    var drawnControls: [A11yControlLayer] = []
    
    lazy var alignmentOverlay = AlignmentOverlayFactory().overlay(for: self)
    
    var copyListener = CopyModifierFactory().make()
    
    var escListener = EscModifierFactory().make()
    
    var hud = HUDLayer()
    
    override func layout() {
        super.layout()
        
        hud.frame = bounds
    }

    // MARK: - Images
    override var intrinsicContentSize: NSSize {
        NSSize(width:  -boundingBox.origin.x + boundingBox.size.width,
               height: boundingBox.origin.y + boundingBox.size.height)
    }
    
    private var defaultBoundingBox: CGRect {
        CGRect(
            origin: .zero,
            size: CGSize(width: 800, height: 400)) // TODO: Understaned default size
    }
    
    private var boundingBox: CGRect {
        guard let sublayers = layer?
            .sublayers?.filter({ layer in
                !(layer is HUDLayer) // Skip HudLayer
            }),
              sublayers.count > 0
        else { return defaultBoundingBox }
        
        let box = sublayers
            .reduce(CGRect.zero) { partialResult, imageView in
                partialResult.union(imageView.frame)
            }
        return box
    }
    
    private var imageLayers: [ImageLayer] {
        (layer?.sublayers ?? [])
            .compactMap { layer in
                layer as? ImageLayer
            }
    }
    
    private func frameImage(at frame: CGRect) -> (CGImage, CGRect)? {
        guard let imageView = imageLayers
            .first(where: { imageView in
                imageView.frame.intersects(frame)
            }), let image = imageView.image
        else { return nil }

        return (image, imageView.frame)
    }
    
    func image(at frame: CGRect) -> CGImage? {
        guard let (image, imageViewFrame) = frameImage(at: frame)
        else { return nil }
        
        let frameInImageCoordinates = frame
            .origin(to: imageViewFrame)
        
        let cgImage = image
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
