import AppKit
import Document

protocol TraitsViewControllerDelegate: AnyObject {
    func didChangeTrait(_ trait: A11yTraits, state: Bool)
}

class TraitsViewController: NSViewController {
    
    weak var delegate: TraitsViewControllerDelegate?
    
    @IBAction func traitDidChange(_ sender: TraitCheckBox) {
        let isOn = sender.state == .on
        
        delegate?.didChangeTrait(sender.trait, state: isOn)
    }
    
    func view() -> TraitsView {
        view as! TraitsView
    }
}
