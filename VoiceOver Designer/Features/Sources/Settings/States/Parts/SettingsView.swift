import AppKit
import Document

class TraitCheckBox: NSButton {
    var trait: A11yTraits!
}

class SettingsView: NSView {
    @IBOutlet weak var resultLabel: NSTextField!
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var mainStack: NSStackView!
    @IBOutlet weak var label: TextRecognitionComboBox!
    var labelText: String {
        get {
            label.stringValue
        }
        set {
            label.stringValue = newValue
        }
    }
    @IBOutlet weak var hint: NSTextField!
    
    @IBOutlet weak var isAccessibilityElementButton: NSButton!
    @IBOutlet weak var isAutofilleEnabled: NSButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.documentView = mainStack
    }
    
    var descr: A11yDescription?
    func setup(from descr: A11yDescription) {
        self.descr = descr
        
        updateText(from: descr)
        
        labelText = descr.label
        hint.stringValue  = descr.hint
        isAccessibilityElementButton.state = descr.isAccessibilityElement ? .on: .off
    }
    
    func updateText(from descr: A11yDescription) {
        resultLabel.attributedStringValue = descr.voiceOverTextAttributed(font: resultLabel.font)
    }
}
