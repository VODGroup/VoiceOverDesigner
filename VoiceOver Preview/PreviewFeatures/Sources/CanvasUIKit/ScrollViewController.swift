import UIKit
import Canvas
import Document

public class ScrollViewController: UIViewController {
    public static func controller(presenter: CanvasPresenter) -> ScrollViewController {
        let storyboard = UIStoryboard(name: "VODesignPreviewViewController",
                                      bundle: .module)
        let scroll = storyboard
            .instantiateInitialViewController() as! ScrollViewController
        scroll.presenter = presenter
        
        return scroll
    }
    
    var presenter: CanvasPresenter!
    var contentController: VODesignPreviewViewController!
    
    public func redraw() {
        contentController.draw()
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.contentController = segue.destination as? VODesignPreviewViewController
        self.contentController.presenter = presenter
        view().canvas = contentController.view()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // TODO: Each frame should be separate controller
        if let imageSize = presenter.document.artboard.frames.first?.frame.size {
            view().scrollView.centerAndScaleToFit(contentSize: imageSize)
            view().updateVoiceOverLayoutForCanvas()
        }
        
        subscribeToVoiceOverNotification()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        view().updateScrollAdjustmentBehaviour()
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
