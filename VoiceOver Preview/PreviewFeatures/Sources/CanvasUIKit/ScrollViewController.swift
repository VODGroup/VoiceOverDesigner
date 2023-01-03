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
        
        fitZoomScaleToImageSize() // Update after rotation
    }

    
    private func fitZoomScaleToImageSize() {
        let imageSize = presenter.document.image?.size ?? UIScreen.main.bounds.size
        view().fitZoomScale(imageSize: imageSize)
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
    
    func fitZoomScale(imageSize: CGSize) {
        let widthScale = scrollView.bounds.width / imageSize.width
        let heightScale = scrollView.bounds.height / imageSize.height
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
    
    private func updateVoiceOverLayoutForCanvas() {
        let yOffset = scrollView.frame.minY - scrollView.bounds.minY
        
        canvas?.updateAccessilibityLayout(yOffset: yOffset)
    }
}
