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

public class A11yControlLayer: CAShapeLayer {
    
    private let config = Config()
    
    public var model: (any AccessibilityView)?
    
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
    }
                                      
    private func layoutResizeMarker() {
        let size: CGFloat = Config().resizeMarkerSize
        resizingMarker.frame = CGRect(origin: CGPoint(x: bounds.maxX - size/2,
                                                      y: bounds.maxY - size/2),
                                      size: CGSize(width: size,
                                                   height: size))
    }
    
    public func updateColor() {
        backgroundColor = model?.color.cgColor
        borderColor = model?.color.cgColor.copy(alpha: 0)
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
    
    private lazy var resizingMarker: CALayer = {
        let marker = ResizeMarker()
        marker.isHidden = true
        
        addSublayer(marker)
        
        return marker
    }()
    
    public var isSelected: Bool = false {
        didSet {
            borderWidth = isSelected ? config.selectedBorderWidth : 0
            borderColor = backgroundColor?.copy(alpha: 1)
//            cornerRadius = isSelected ? config.selectedCornerRadius : config.normalCornerRadius
            if #available(macOS 10.15, *) {
                cornerCurve = .continuous
            }
            
            resizingMarker.isHidden = !isSelected
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

