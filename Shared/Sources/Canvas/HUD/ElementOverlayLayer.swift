import QuartzCore
import Document

class ElementOverlayLayer: CALayer {
    
    var tintColor: CGColor? {
        didSet {
            updateWithoutAnimation {
                border.strokeColor = tintColor
            }
        }
    }
    
    let border = CAShapeLayer()
    private var resizingMarkers: [ResizeMarker] = [
        ResizeMarker(),
        ResizeMarker(),
        ResizeMarker(),
        ResizeMarker(),
    ]
    
    public override init() {
        self.tintColor = Color.black.cgColor
        self.resizeMarkerSize = 4
        self.resizeMarkerLineWidth = 2
        self.borderLineWidth = 1
        
        super.init()
        
        border.fillColor = Color.clear.cgColor
        addSublayer(border)
        
        resizingMarkers.forEach { marker in
            addSublayer(marker)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: Any) {
        let layer = layer as! ElementOverlayLayer
        self.tintColor = layer.tintColor
        self.resizeMarkerSize = layer.resizeMarkerSize
        self.resizeMarkerLineWidth = layer.resizeMarkerLineWidth
        self.borderLineWidth = layer.borderLineWidth
        
        super.init(layer: layer)
    }
    
    override public func layoutSublayers() {
        super.layoutSublayers()
        
        updateWithoutAnimation {
            border.lineWidth = borderLineWidth
            
            layoutResizeMarker()
            border.path = CGPath(roundedRect: bounds,
                                 cornerWidth: cornerRadius,
                                 cornerHeight: cornerRadius,
                                 transform: nil)
            border.frame = bounds
        }
    }
    
    var resizeMarkerSize: CGFloat {
        didSet {
            setNeedsLayout()
        }
    }
    
    var resizeMarkerLineWidth: CGFloat {
        didSet {
            setNeedsLayout()
        }
    }
    
    var borderLineWidth: CGFloat {
        didSet {
            setNeedsLayout()
        }
    }
                                      
    private func layoutResizeMarker() {
        resizingMarkers[0].frame = bounds.frame(corner: .topLeft, size: resizeMarkerSize)
        resizingMarkers[1].frame = bounds.frame(corner: .topRight, size: resizeMarkerSize)
        resizingMarkers[2].frame = bounds.frame(corner: .bottomLeft, size: resizeMarkerSize)
        resizingMarkers[3].frame = bounds.frame(corner: .bottomRight, size: resizeMarkerSize)
        
        for marker in resizingMarkers {
            marker.lineWidth = resizeMarkerLineWidth
        }
    }
}
