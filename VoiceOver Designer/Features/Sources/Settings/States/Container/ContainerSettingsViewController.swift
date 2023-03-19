import AppKit
import Document
import TextRecognition

class ContainerSettingsViewController: NSViewController {
    
    public var presenter: ContainerSettingsPresenter!
    
    weak var labelViewController: LabelViewController?
    
    public override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.destinationController {
        case let labelViewController as LabelViewController:
            self.labelViewController = labelViewController
            labelViewController.delegate = presenter
            labelViewController.view().labelText = presenter.container.label
            
        default: break
        }
    }
    
    func view() -> ContainerSettingsView {
        view as! ContainerSettingsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderSettings()
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
