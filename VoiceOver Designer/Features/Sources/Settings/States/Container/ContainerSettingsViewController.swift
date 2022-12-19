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
        
        view().isModal = presenter.container.isModal
        view().isTabTrait = presenter.container.isTabTrait
        view().isEnumerated = presenter.container.isEnumerated
    }
    
    @IBAction func didChangeContainerType(sender: Any) {
        
    }
    
    @IBAction func didChangeNavigationStyle(sender: Any) {
        
    }
    
    @IBAction func isModalDidChanged(sender: Any) {
        presenter.container.isModal = view().isModal
    }
    
    @IBAction func isTabDidChanged(sender: Any) {
        presenter.container.isTabTrait = view().isTabTrait
    }
    
    @IBAction func isEnumerateDidChanged(sender: Any) {
        presenter.container.isEnumerated = view().isEnumerated
    }
}

extension ContainerSettingsViewController: LabelDelegate {
    func updateLabel(to text: String) {
        presenter.updateLabel(to: text)
    }
}

extension ContainerSettingsViewController: TextRecogitionReceiver {
    
    public func presentTextRecognition(_ alternatives: [String]) {
        guard labelViewController?.view().isAutofillEnabled ?? false else { return }
        
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

class ContainerSettingsView: NSView {
    
    var isModal: Bool {
        get {
            isModalButton.state == .on
        }
        
        set {
            isModalButton.state = newValue ? .on: .off
        }
    }
    
    var isTabTrait: Bool {
        get {
            isTabTraitButton.state == .on
        }
        
        set {
            isTabTraitButton.state = newValue ? .on: .off
        }
    }
    
    var isEnumerated: Bool {
        get {
            isEnumeratedButton.state == .on
        }
        
        set {
            isEnumeratedButton.state = newValue ? .on: .off
        }
    }
    
    @IBOutlet private var containerTypeSegmentedControl: NSSegmentedControl!
    @IBOutlet private var navigationStyleSegmentedControl: NSSegmentedControl!
    @IBOutlet private var isModalButton: NSButton!
    @IBOutlet private var isTabTraitButton: NSButton!
    @IBOutlet private var isEnumeratedButton: NSButton!
}
