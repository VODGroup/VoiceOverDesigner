import AppKit

import CommonUI
import Document
import Canvas

class ContentView: FlippedView, DrawingView {
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
        boundingBox.size
    }
    
    private var defaultBoundingBox: CGRect {
        CGRect(
            origin: .zero,
            size: CGSize(width: 800, height: 400)) // TODO: Understaned default size
    }
    
    private var boundingBox: CGRect {
        guard let sublayers = layer?.sublayers,
              sublayers.count > 1 // Skip HUDLayer
        else { return defaultBoundingBox }
        
        let box = sublayers
            .reduce(CGRect.zero) { partialResult, imageView in
                partialResult.union(imageView.frame)
            }
        return box
    }
    
    private func frameImage(at frame: CGRect) -> (Image, CGRect)? {
        return nil // TODO: Restore text recognition
//        guard let imageView = imageViews.first(where: { imageView in
//            imageView.frame.intersects(frame)
//        }), let image = imageView.image
//        else { return nil }
//
//        return (image, imageView.frame)
    }
    
    func image(at frame: CGRect) -> CGImage? {
        guard let (image, imageViewFrame) = frameImage(at: frame)
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
