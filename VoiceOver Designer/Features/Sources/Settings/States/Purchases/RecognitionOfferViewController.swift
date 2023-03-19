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
            view().isLoading = true
            do {
                let price = try await presenter.fetchProduct()
                view().display(price: price)
            } catch let error {
//                view().display(error: error, at: .purchaseButton)
                // No need to display error: user can press 'purchase' button without price and product will be fetched anyway
            }
            
            view().isLoading = false
        }
    }
    
    @IBAction func purchaseTextRecognition(_ sender: Any) {
        Task {
            view().isLoading = true
            
            do {
                try await presenter.purchase()
            } catch let error {
                view().display(error: error, at: .restoreButton)
            }
            
            view().isLoading = false
        }
    }
    
    @IBAction func restorePurchase(_ sender: Any) {
        Task {
            view().isLoading = true
            do {
                try await presenter.restore()
                // Unlock status will be send by delegate to parent controller to remove this UI
            } catch let error {
                view().display(error: error, at: .restoreButton)
            }
            view().isLoading = false
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
