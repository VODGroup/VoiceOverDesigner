import AppKit
import Purchases

class RecognitionOfferViewController: NSViewController {

    let presenter = UnlockPresenter(productId: .textRecognition)
    
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
            } catch let error {
                view().display(error: error, at: .restoreButton)
            }
        }
    }
    
    @MainActor
    func view() -> RecognitionOfferView {
        view as! RecognitionOfferView
    }
}

protocol UnlockPresenterDelegate: AnyObject {
    func didChangeUnlockStatus(productId: ProductId)
}

class UnlockPresenter {
    
    enum PaymentError: Error {
        case canNotFetchProducts
    }
    
    let productId: ProductId
    init(productId: ProductId) {
        self.productId = productId
    }
    
    weak var delegate: UnlockPresenterDelegate?
    
    func isUnlocked() -> Bool {
        return false
    }
    
    let store = Store()
    
    func fetchProduct() async throws -> String {
        await store.listenForUpdates()
        
        let product = try await store.product(id: productId)
        
        if let price = product?.displayPrice {
            return price
        } else {
            throw PaymentError.canNotFetchProducts
        }
    }
    
    func purchase() async throws {
        guard let product = try await store.product(id: productId)
        else { return }
        
        try await store.purchase(product: product)
    }
    
    func restore() async throws {
        try await store.restore()
    }
}
