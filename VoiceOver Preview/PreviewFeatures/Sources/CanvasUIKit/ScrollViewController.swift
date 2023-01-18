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
    }

    
    func view() -> ScrollView {
        view as! ScrollView
    }
}

class ScrollView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var container: UIView!
    
    weak var canvas: VODesignPreviewView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.maximumZoomScale = 4
    }
    
    func fitZoomScale() {
        let widthScale = scrollView.bounds.width / scrollView.contentSize.width
        let heightScale = scrollView.bounds.height / scrollView.contentSize.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
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
        
        let scale = updateZoomScaleToFitContent()
        
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
    
    func updateZoomScaleToFitContent() -> CGFloat {
        let widthScale  = bounds.width  / contentSize.width
        let heightScale = bounds.height / contentSize.height
        let minScale    = min(widthScale, heightScale)
        
        minimumZoomScale = minScale
        zoomScale = minScale
        return minScale
    }
}
