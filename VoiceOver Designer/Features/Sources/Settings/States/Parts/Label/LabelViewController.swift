import AppKit
import Document
import TextRecognition

protocol LabelDelegate: AnyObject {
    func updateLabel(to text: String)
}

class LabelViewController: NSViewController {
    
    weak var delegate: LabelDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view().isAutofillEnabled = settingStorage.isAutofillEnabled
    }
    
    private let settingStorage = SettingsStorage()
    
    // MARK: Actions
    @IBAction func labelDidChange(_ sender: NSTextField) {
        // TODO: if you forgot to call updateColor, the label wouldn't be revalidated
        delegate?.updateLabel(to: sender.stringValue)
    }
    
    @IBAction func isAutofillDidChanged(_ sender: NSButton) {
        settingStorage.isAutofillEnabled = sender.state == .on
    }
    
    // MARK: Text Recognition
    public func presentTextRecognition(_ alternatives: [String]) {
        print("Recognition results \(alternatives)")
        
        guard view().isAutofillEnabled else { return }
        
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
    
    @IBOutlet weak var isAutofillEnabledButton: NSButton!
    var isAutofillEnabled: Bool {
        get {
            isAutofillEnabledButton.state == .on
        }
        
        set {
            isAutofillEnabledButton.state = newValue ? .on: .off
        }
    }
}
