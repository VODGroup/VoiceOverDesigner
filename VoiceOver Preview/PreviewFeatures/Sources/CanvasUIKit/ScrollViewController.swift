import UIKit
import Canvas
import VoiceOverLayout
import Document

public class ScrollViewController: UIViewController {
    public static func controller(presenter: CanvasPresenter) -> UIViewController {
        let storyboard = UIStoryboard(name: "VODesignPreviewViewController",
                                      bundle: .module)
        let scroll = storyboard
            .instantiateInitialViewController() as! ScrollViewController
        scroll.presenter = presenter
        
        return scroll
    }
    
    var presenter: CanvasPresenter!
    var contentController: VODesignPreviewViewController!
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.contentController = segue.destination as? VODesignPreviewViewController
        self.contentController.presenter = presenter
        view().canvas = contentController.view()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let imageSize = presenter.document.imageSize
        view().scrollView.centerAndScaleToFit(contentSize: imageSize)
        
        subscribeToVoiceOverNotification()
    }

    
    func view() -> ScrollView {
        view as! ScrollView
    }
    
    func subscribeToVoiceOverNotification() {
        func updateVoiceOverHintToCurrentState() {
            view().isVoiceOverHintHidden = UIAccessibility.isVoiceOverRunning
        }
        
        updateVoiceOverHintToCurrentState()
        
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil, queue: .main
        ) { notifiaction in
            UIView.animate(withDuration: 0.3, delay: 0) {
                updateVoiceOverHintToCurrentState()
            }
        }
    }
}

class ScrollView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var container: UIView!
    
    weak var canvas: VODesignPreviewView?
    
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
            
        }
    }
}

extension ScrollView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateVoiceOverLayoutForCanvas()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        container
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        scrollView.updateContentInsetToCenterContent()
    }
    
    private func updateVoiceOverLayoutForCanvas() {
        let yOffset = scrollView.frame.minY - scrollView.bounds.minY
        
        canvas?.updateAccessilibityLayout(yOffset: yOffset)
    }
}

extension UIScrollView {
    
    func centerAndScaleToFit(contentSize: CGSize) {
        self.contentSize = contentSize
        
        /// Fit to width for iPhone, keep image width for iPhone's screen on iPad
        let minimalWidth = min(bounds.width, contentSize.width/UIScreen.main.scale) // Probaly scale should be got from document
        let scale = updateZoomScaleToFitContent(width: minimalWidth)
        
        // We had to calculate manually because first layout do it wrong
        let scaledContentSize = CGSize(width: contentSize.width * scale,
                                       height: contentSize.height * scale)
        updateContentInsetToCenterContent(contentSize: scaledContentSize)
    }
    
    func updateContentInsetToCenterContent(contentSize: CGSize) {
        let offsetX = max((bounds.width  - contentSize.width)  * 0.5, 0)
        let offsetY = max((bounds.height - contentSize.height) * 0.5, 0)
    
        contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
    
    func updateZoomScaleToFitContent(width: CGFloat) -> CGFloat {
        let widthScale  = width  / contentSize.width
        let minScale    = widthScale
        
        minimumZoomScale = widthScale
        zoomScale = minScale
        return minScale
    }
}
