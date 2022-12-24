import QuartzCore
import Document

struct Config {
    let selectedBorderWidth: CGFloat = 4
    let selectedCornerRadius: CGFloat = 4
    
    let highlightedAlpha: CGFloat = 0.75
    let normalAlpha: CGFloat = 0.5
    let normalCornerRadius: CGFloat = 0
    
    let fontSize: CGFloat = 10
    
    let resizeMarkerSize: CGFloat = 30
    let alignmentThreshold: CGFloat = 5
}

public class A11yControlLayer: CALayer {
    
    private let config = Config()
    
    public var model: (any AccessibilityView)?
    private var border = CAShapeLayer()
    
    public override init() {
        super.init()
        
        border.lineWidth = 10
        addSublayer(border)
        
        
        resizingMarkers.forEach { marker in
            addSublayer(marker)
            marker.isHidden = true
        }
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        let layer = layer as! A11yControlLayer
        self.model = layer.model
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var label: CATextLayer? = {
        let label = CATextLayer()
        label.string = model?.label
        label.fontSize = config.fontSize
        label.foregroundColor = Color.white.cgColor
        label.backgroundColor = Color.systemGray.withAlphaComponent(0.7).cgColor
        let size = label.preferredFrameSize()
        label.frame = .init(origin: .zero, size: size).offsetBy(dx: 0, dy: -size.height - 1)
        label.contentsScale = contentsScale
        return label
    }()
    
    override public func layoutSublayers() {
        super.layoutSublayers()
        
        if let size = label?.preferredFrameSize() {
            label?.frame = .init(origin: .zero, size: size)
                .offsetBy(dx: 0, dy: -size.height - 1)
        }
        
        updateWithoutAnimation {
            layoutResizeMarker()
        }
        
        border.frame = bounds
    }
                                      
    private func layoutResizeMarker() {
        resizingMarkers[0].frame = markerFrame(center: CGPoint(x: bounds.minX, y: bounds.minY))
        resizingMarkers[1].frame = markerFrame(center: CGPoint(x: bounds.minX, y: bounds.maxY))
        resizingMarkers[2].frame = markerFrame(center: CGPoint(x: bounds.maxX, y: bounds.maxY))
        resizingMarkers[3].frame = markerFrame(center: CGPoint(x: bounds.maxX, y: bounds.minY))
    }
    
    private func markerFrame(center: CGPoint) -> CGRect {
        let size: CGFloat = Config().resizeMarkerSize
        return CGRect(origin: CGPoint(x: center.x - size/2,
                                      y: center.y - size/2),
                      size: CGSize(width: size,
                                   height: size))
        
    }
    
    public func updateColor() {
        backgroundColor = model?.color.cgColor
        border.strokeColor = model?.color.cgColor.copy(alpha: 0)
    }
    
    public override var frame: CGRect {
        didSet {
            model?.frame = frame
        }
    }
    
    public var isHiglighted: Bool = false {
        didSet {
            let alpha = isHiglighted
            ? config.highlightedAlpha
            : config.normalAlpha
            
            backgroundColor = backgroundColor?.copy(alpha: alpha)
        }
    }
    
    private var resizingMarkers: [CALayer] = [
        ResizeMarker(),
        ResizeMarker(),
        ResizeMarker(),
        ResizeMarker(),
    ]
    
    public var isSelected: Bool = false {
        didSet {
            border.lineWidth = isSelected ? config.selectedBorderWidth : 0
            border.strokeColor = backgroundColor?.copy(alpha: 1)
//            cornerRadius = isSelected ? config.selectedCornerRadius : config.normalCornerRadius
            if #available(macOS 10.15, *) {
                cornerCurve = .continuous
            }
            
            resizingMarkers.forEach { marker in
                marker.isHidden = !isSelected
            }
        }
    }
    
    public func addLabel() {
        if let label = label {
            addSublayer(label)
        }
    }
    
    public func removeLabel() {
        label?.removeFromSuperlayer()
    }
}

public extension A11yControlLayer {
    static func copy(from model: any AccessibilityView) -> A11yControlLayer {
        let control = A11yControlLayer()
        control.model = model
        control.backgroundColor = model.color.cgColor
        control.frame = model.frame
        return control
    }
}

