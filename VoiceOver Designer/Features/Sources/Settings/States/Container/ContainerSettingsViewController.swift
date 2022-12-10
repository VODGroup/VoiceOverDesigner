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
