import AppKit
import Purchases

class RecognitionOfferViewController: NSViewController {

    var presenter: UnlockPresenter!
    func inject(presenter: UnlockPresenter) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                let price = try await presenter.fetchProduct()
                view().display(price: price)
            } catch let error {
                view().display(error: error, at: .purchaseButton)
            }
        }
    }
    
    @IBAction func purchaseTextRecognition(_ sender: Any) {
        Task {
            do {
                try await presenter.purchase()
            } catch let error {
                view().display(error: error, at: .restoreButton)
            }
        }
    }
    
    @IBAction func restorePurchase(_ sender: Any) {
        Task {
            do {
                try await presenter.restore()
                // Unlock status will be send to parent controller to remove this UI
            } catch let error {
                view().display(error: error, at: .restoreButton)
            }
        }
    }
    
    @MainActor
    func view() -> RecognitionOfferView {
        view as! RecognitionOfferView
    }
    
    static func fromStoryboard() -> RecognitionOfferViewController {
        NSStoryboard(name: "RecognitionOfferViewController", bundle: .module)
            .instantiateInitialController() as! RecognitionOfferViewController
    }
}
