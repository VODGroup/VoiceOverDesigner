import AppKit
import Document

class TraitCheckBox: NSButton {
    var trait: A11yTraits!
}

class SettingsView: NSView {
    @IBOutlet weak var resultLabel: NSTextField!
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var mainStack: NSStackView!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var hint: NSTextField!
    
    // MARK: Type trait
    @IBOutlet weak var buttonTrait: TraitCheckBox!
    @IBOutlet weak var headerTrait: TraitCheckBox!
    
    @IBOutlet weak var linkTrait: TraitCheckBox!
    @IBOutlet weak var staticTextTrait: TraitCheckBox!
    @IBOutlet weak var imageTrait: TraitCheckBox!
    @IBOutlet weak var searchFieldTrait: TraitCheckBox!
    @IBOutlet weak var tabTrait: TraitCheckBox!
    
    @IBOutlet weak var selectedTrait: TraitCheckBox!
    @IBOutlet weak var summaryElementTrait: TraitCheckBox!
    @IBOutlet weak var playSoundTrait: TraitCheckBox!
    @IBOutlet weak var allowsDirectInteraction: TraitCheckBox!
    @IBOutlet weak var startMediaSession: TraitCheckBox!
    @IBOutlet weak var disabledTrait: TraitCheckBox!
    @IBOutlet weak var updatesFrequently: TraitCheckBox!
    @IBOutlet weak var causesPageTurn: TraitCheckBox!
    @IBOutlet weak var keyboardKey: TraitCheckBox!
    
    @IBOutlet weak var isAccessibilityElementButton: NSButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.documentView = mainStack
    }
    
    var descr: A11yDescription?
    func setup(from descr: A11yDescription) {
        self.descr = descr
        
        updateText(from: descr)
        
        label.stringValue = descr.label
        hint.stringValue  = descr.hint
        isAccessibilityElementButton.state = descr.isAccessibilityElement ? .on: .off
        
        buttonTrait.trait = .button
        headerTrait.trait = .header
        linkTrait.trait = .link
        staticTextTrait.trait = .staticText
        imageTrait.trait = .image
        searchFieldTrait.trait = .searchField
        tabTrait.trait = .tab
        
        selectedTrait.trait = .selected
        summaryElementTrait.trait = .summaryElement
        playSoundTrait.trait = .playsSound
        allowsDirectInteraction.trait = .allowsDirectInteraction
        startMediaSession.trait = .startsMediaSession
        disabledTrait.trait = .notEnabled
        updatesFrequently.trait = .updatesFrequently
        causesPageTurn.trait = .causesPageTurn
        keyboardKey.trait = .keyboardKey
        
        let allTraitsButtons: [TraitCheckBox] = [
            buttonTrait,
            headerTrait,
            linkTrait,
            staticTextTrait,
            imageTrait,
            searchFieldTrait,
            tabTrait,
            
            selectedTrait,
            summaryElementTrait,
            playSoundTrait,
            allowsDirectInteraction,
            startMediaSession,
            disabledTrait,
            updatesFrequently,
            causesPageTurn,
            keyboardKey,
        ]
        
        for traitButton in allTraitsButtons {
            traitButton.state = descr.trait.contains(traitButton.trait) ? .on: .off
        }
    }
    
    func updateText(from descr: A11yDescription) {
        resultLabel.stringValue = descr.voiceOverText
    }
}
