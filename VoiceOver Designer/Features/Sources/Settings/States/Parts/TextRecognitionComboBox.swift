import AppKit

class TextRecognitionComboBox: NSComboBox {
   
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonSetup()
    }
    
    func commonSetup() {
        isAutomaticTextCompletionEnabled = true
        bezelStyle = .roundedBezel
        isEditable = true
    }
}
