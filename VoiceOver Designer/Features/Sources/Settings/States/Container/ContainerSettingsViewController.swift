import AppKit
import Document
import TextRecognition
import Purchases

class ContainerSettingsViewController: NSViewController {
    
    var presenter: ContainerSettingsPresenter!
    var textRecognitionUnlockPresenter: UnlockPresenter!
    
    weak var labelViewController: LabelViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderSettings()
    }
    
    public override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.destinationController {
        case let labelViewController as LabelViewController:
            self.labelViewController = labelViewController
            labelViewController.delegate = presenter
            labelViewController.textRecognitionUnlockPresenter = textRecognitionUnlockPresenter
            
        default: break
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // TODO: Setup inside controllers?
        labelViewController?.view().labelText = presenter.container.label
    }
    
    func view() -> ContainerSettingsView {
        view as! ContainerSettingsView
    }
    
    func renderSettings() {
        view().renderSettings(container: presenter.container)
    }
    
    @IBAction func didChangeContainerType(sender: Any) {
        presenter.container.containerType = view().containerType
    }
    
    @IBAction func didChangeNavigationStyle(sender: Any) {
        presenter.container.navigationStyle = view().navigationStyle
    }
    
    @IBAction func isModalDidChanged(sender: Any) {
        presenter.container.isModal = view().isModal
    }
    
    @IBAction func isTabDidChanged(sender: Any) {
        let isTab = view().isTabTrait
        presenter.container.isTabTrait = isTab
        
        if isTab {
            // Tab trait enumerates itself
            presenter.container.isEnumerated = false
        }
        
        renderSettings()
    }
    
    @IBAction func isEnumerateDidChanged(sender: Any) {
        presenter.container.isEnumerated = view().isEnumerated
    }
    
    @IBAction func delete(sender: Any) {
        presenter.delete()
    }
}

extension ContainerSettingsViewController: LabelDelegate {
    func updateLabel(to text: String) {
        presenter.updateLabel(to: text)
    }
}

extension ContainerSettingsViewController: TextRecogitionReceiver {
    
    public func presentTextRecognition(_ alternatives: [String]) {
        labelViewController?.presentTextRecognition(alternatives)
    }
}

extension ContainerSettingsViewController {
    public static func fromStoryboard() -> ContainerSettingsViewController {
        let storyboard = NSStoryboard(name: "ContainerSettingsViewController",
                                      bundle: .module)
        return storyboard.instantiateInitialController() as! ContainerSettingsViewController
    }
}

extension ContainerSettingsViewController: UnlockerDelegate {
    public func didChangeUnlockStatus(productId: ProductId) {
        switch productId {
        case .textRecognition:
            labelViewController?.hidePaymentController()
        }
    }
}
