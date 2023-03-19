import AppKit
import Purchases

class RecognitionOfferViewController: NSViewController {

    let store = Store()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                // TODO: Call it at another place without link to controller
                await store.listenForUpdates()
                let product = try await store.product(id: .textRecognition)
                
                if let price = product?.displayPrice {
                    view().display(price: price)
                } else {
                    // TODO: Same as error
                }
            } catch let error {
                print(error) // TODO: Handle error
            }
        }
    }
    
    @IBAction func purchaseTextRecognition(_ sender: Any) {
        Task {
            guard let textRecognitionProduct = try await store.product(id: .textRecognition) else {
                return
            }
            
            try await store.purchase(product: textRecognitionProduct)
        }
        
    }
    
    @IBAction func restorePurchase(_ sender: Any) {
        Task {
            do {
                try await store.restore()
            } catch let error {
                print(error)
                // TODO: Improve here
            }
        }
    }
    
    @MainActor
    func view() -> RecognitionOfferView {
        view as! RecognitionOfferView
    }
}
