import AppKit
import Document

class ContainerSettingsView: NSView {
    
    func renderSettings(container: A11yContainer) {
        isModal         = container.isModal
        isTabTrait      = container.isTabTrait
        isEnumerated    = container.isEnumerated
        isEnumeratedEnabled = !container.isTabTrait
        containerType   = container.containerType
        navigationStyle = container.navigationStyle
        treatAsAdjustable = container.treatButtonsAsAdjustable
        canTreatAsAdjustable = container.canTraitAsAdjustable
    }
    
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
    
    var isEnumeratedEnabled: Bool {
        set {
            isEnumeratedButton.isEnabled = newValue
        }
        
        get {
            isEnumeratedButton.isEnabled
        }
    }
    
    var treatAsAdjustable: Bool {
        get {
            treatAsAdjustableButton.state == .on
        }
        
        set {
            treatAsAdjustableButton.state = newValue ? .on: .off
        }
    }
    
    var canTreatAsAdjustable: Bool {
        set {
            treatAsAdjustableButton.isEnabled = newValue
        }
        
        get {
            treatAsAdjustableButton.isEnabled
        }
    }
    
    var containerType: A11yContainer.ContainerType {
        set {
            // TODO: Make relation between labels on UI and `allCases`
            containerTypeSegmentedControl.selectedSegment = A11yContainer.ContainerType.allCases.firstIndex(of: newValue)!
        }
        
        get {
            let selected = containerTypeSegmentedControl.selectedSegment
            return A11yContainer.ContainerType.allCases[selected]
        }
    }
    
    var navigationStyle: A11yContainer.NavigationStyle {
        set {
            navigationStyleSegmentedControl.selectedSegment = A11yContainer.NavigationStyle.allCases.firstIndex(of: newValue)!
        }
        
        get {
            let selected = navigationStyleSegmentedControl.selectedSegment
            return A11yContainer.NavigationStyle.allCases[selected]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        treatAsAdjustableButton.toolTip =
        NSLocalizedString("""
Separate buttons is great for Switch Control and Voice Control, but for VoiceOver it's better to union in single adjustable element that changes its value by vertical swipe

Requires at least 2 elements with .button trait
""", comment: "Tooltip")
    }
    
    @IBOutlet private var containerTypeSegmentedControl: NSSegmentedControl!
    @IBOutlet private var navigationStyleSegmentedControl: NSSegmentedControl!
    @IBOutlet private var isModalButton: NSButton!
    @IBOutlet private var isTabTraitButton: NSButton!
    @IBOutlet private var isEnumeratedButton: NSButton!
    @IBOutlet private var treatAsAdjustableButton: NSButton!
}
