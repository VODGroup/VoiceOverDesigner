import UIKit
import Canvas
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
        view().updateVoiceOverLayoutForCanvas()
        
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
