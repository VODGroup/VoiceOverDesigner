import UIKit
import VoiceOverLayout

class ScrollView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var container: UIView!
    
    weak var canvas: VODesignPreviewView?
    var layout: VoiceOverLayout?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.maximumZoomScale = 4
        
        voiceOverHint.layer.shadowOpacity = 0.25
        voiceOverHint.layer.shadowOffset = CGSize(width: 0, height: 5)
        voiceOverHint.layer.shadowRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = voiceOverHint.frame.height/2
        voiceOverHint.layer.cornerRadius = radius
        voiceOverHint.layer.cornerCurve = .continuous
        
        voiceOverHint.layer.shadowPath = UIBezierPath(roundedRect: voiceOverHint.bounds,
                                                      cornerRadius: radius).cgPath
    }
    
    @IBOutlet weak var voiceOverHint: UIView!
    
    var isVoiceOverHintHidden: Bool = false {
        didSet {
            voiceOverHint.transform = CGAffineTransform(
                translationX: 0,
                y: isVoiceOverHintHidden ? 150: 0)
            
            // Layout depends on current assistive technology
            invalidateVoiceOverLayout()
        }
    }
}

extension ScrollView: UIScrollViewDelegate {


    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let elements = container.accessibilityElements {
            layout?.updateContainers(in: elements)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        container
    }
    
    private func invalidateVoiceOverLayout() {
        layout = nil
        updateVoiceOverLayoutForCanvas()
    }
    
    func updateVoiceOverLayoutForCanvas() {
        guard let canvas = canvas else {
            return
        }
        
        if layout == nil {
            layout = VoiceOverLayout(
                controls: canvas.controls,
                scrollView: scrollView)
        }
        
        container.accessibilityElements = layout!.accessibilityElements(at: container)
    }
}
