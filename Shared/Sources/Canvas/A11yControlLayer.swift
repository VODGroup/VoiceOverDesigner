import QuartzCore
import Document

struct Config {
    let selectedBorderWidth: CGFloat = 4
    let selectedCornerRadius: CGFloat = 4
    
    let highlightedAlpha: CGFloat = 0.75
    let normalAlpha: CGFloat = 0.5
    let normalCornerRadius: CGFloat = 0
    
    let fontSize: CGFloat = 10
    
    let resizeMarkerSize: CGFloat = 10
    let alignmentThreshold: CGFloat = 5
}

public class A11yControlLayer: ArtboardElementLayer {
    
    private let config = Config()
    
    public func update(
        to relativeFrame: CGRect,
        in view: DrawingView
    ) {
        frame = relativeFrame
        
        let absoluteFrame = view.absoluteFrame(
            of: frame,
            for: self)
//        print("Set frame to model \(absoluteFrame)")
        
        model?.frame = absoluteFrame
    }
    
    public var isHighlighted: Bool = false {
        didSet {
            let alpha = isHighlighted
            ? config.highlightedAlpha
            : config.normalAlpha
            
            backgroundColor = backgroundColor?.copy(alpha: alpha)
        }
    }
}

public extension A11yControlLayer {
    static func copy(from model: any ArtboardElement) -> A11yControlLayer {
        let control = A11yControlLayer(model: model)
        control.frame = model.frame
        control.backgroundColor = model.color.cgColor
        return control
    }
}

