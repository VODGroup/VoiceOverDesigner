import AppKit
import Document
import TextRecognition
import Purchases

protocol LabelDelegate: AnyObject {
    func updateLabel(to text: String)
}

class LabelViewController: NSViewController {
    
    weak var delegate: LabelDelegate?
    var textRecognitionUnlockPresenter: UnlockPresenter!
    
    private let settingStorage = SettingsStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !textRecognitionUnlockPresenter.isUnlocked() {
            embedTextRecognitionOffer()
        }
    }
    
    private weak var purchaseController: NSViewController?
    private func embedTextRecognitionOffer() {
        let purchaseController = RecognitionOfferViewController.fromStoryboard()
        purchaseController.inject(presenter: textRecognitionUnlockPresenter)
        
        self.purchaseController = purchaseController // keep ref to remove later
        
        addChild(purchaseController)
        view().insertPurchaseControllerView(purchaseController.view)
    }
    
    func hidePaymentController() {
        purchaseController?.view.removeFromSuperview()
        purchaseController?.removeFromParent()
    }
    
    // MARK: Actions
    @IBAction func labelDidChange(_ sender: NSTextField) {
        // TODO: if you forgot to call updateColor, the label wouldn't be revalidated
        delegate?.updateLabel(to: sender.stringValue)
    }
    
    // MARK: Text Recognition
    public func presentTextRecognition(_ alternatives: [String]) {
        print("Recognition results \(alternatives)")
        
        view().label.addItems(withObjectValues: alternatives)
        
        if view().labelText.isEmpty,
           let first = alternatives.first
        {
            view().labelText = first
            delegate?.updateLabel(to: first)
        }
    }
    
    func view() -> LabelView {
        view as! LabelView
    }
}

class LabelView: NSView {
    @IBOutlet weak var label: TextRecognitionComboBox!
    var labelText: String {
        get {
            label.stringValue
        }
        set {
            label.stringValue = newValue
        }
    }
    
    @IBOutlet weak var mainStack: NSStackView!
    
    func insertPurchaseControllerView(_ view: NSView) {
        mainStack.insertView(view,
                             at: 0, 
                             in: .top)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
    }
}
