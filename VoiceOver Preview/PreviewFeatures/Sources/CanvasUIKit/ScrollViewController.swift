import UIKit
import Canvas

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
        self.contentController = segue.destination as! VODesignPreviewViewController
        self.contentController.presenter = presenter
    }
}

class ScrollView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var container: UIView!
}

extension ScrollView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateVoiceOverLayoutForCanvas()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        container
    }
    
    private func updateVoiceOverLayoutForCanvas() {
        let offset = scrollView.frame.minY - scrollView.bounds.minY
        
//        canvas.layout = VoiceOverLayout(
//            controls: controls,
//            container: canvas,
//            yOffset: offset)
    }
}
