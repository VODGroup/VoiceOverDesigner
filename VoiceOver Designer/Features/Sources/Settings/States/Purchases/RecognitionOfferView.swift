import AppKit

class RecognitionOfferView: NSView {
    
    @IBOutlet weak var toastView: NSView!
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var bodyLabel: NSTextField!
    
    @IBOutlet weak var activateButton: NSButton!
    @IBOutlet weak var restoreButton: NSButton!
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                loadingIndicator.startAnimation(self)
            } else {
                loadingIndicator.stopAnimation(self)
            }
        }
    }
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        toastView.wantsLayer = true
//        toastView.layer?.backgroundColor = NSColor.systemPurple.cgColor
        toastView.layer?.borderWidth = 2
        toastView.layer?.borderColor = NSColor.systemPurple.cgColor
        
        toastView.layer?.cornerRadius = 8
        toastView.layer?.cornerCurve = .continuous
    }
    
    func display(price: String) {
        activateButton.title = NSLocalizedString(String.localizedStringWithFormat("Activate text recognition for %@", price), comment: "Button's title")
    }
    
    func display(error: Error, at: ErrorPlace) {
        print(error)
        
        let alert = NSAlert(error: error)
        alert.runModal()
    }
    
    enum ErrorPlace {
        case purchaseButton
        case restoreButton
    }
}

// TODO: Use it
class TintedBorderView: NSView {
    
    
}
