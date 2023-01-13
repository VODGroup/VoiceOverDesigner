import AppKit
import Document

class TraitsView: NSView {
    @IBOutlet weak var buttonTrait: TraitCheckBox!
    @IBOutlet weak var selectedTrait: TraitCheckBox!
    @IBOutlet weak var disabledTrait: TraitCheckBox!
    @IBOutlet weak var switcher: TraitCheckBox!
    @IBOutlet weak var linkTrait: TraitCheckBox!
    @IBOutlet weak var imageTrait: TraitCheckBox!
    
    @IBOutlet weak var updatesFrequently: TraitCheckBox!
    @IBOutlet weak var summaryElementTrait: TraitCheckBox!
    @IBOutlet weak var playSoundTrait: TraitCheckBox!
    @IBOutlet weak var startMediaSession: TraitCheckBox!
    @IBOutlet weak var allowsDirectInteractionTrait: TraitCheckBox!
    @IBOutlet weak var causesPageTurn: TraitCheckBox!

    @IBOutlet weak var headerTrait: TraitCheckBox!
    @IBOutlet weak var textInput: TraitCheckBox!
    @IBOutlet weak var isEditingText: TraitCheckBox!
    @IBOutlet weak var staticTextTrait: TraitCheckBox!
    @IBOutlet weak var searchFieldTrait: TraitCheckBox!
    @IBOutlet weak var keyboardKey: TraitCheckBox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonTrait.trait = .button
        selectedTrait.trait = .selected
        disabledTrait.trait = .notEnabled
        switcher.trait = .switcher
        linkTrait.trait = .link
        imageTrait.trait = .image
        
        updatesFrequently.trait = .updatesFrequently
        summaryElementTrait.trait = .summaryElement
        playSoundTrait.trait = .playsSound
        startMediaSession.trait = .startsMediaSession
        allowsDirectInteractionTrait.trait = .allowsDirectInteraction
        causesPageTurn.trait = .causesPageTurn
        
        headerTrait.trait = .header
        textInput.trait = .textInput
        isEditingText.trait = .isEditingTextInput
        staticTextTrait.trait = .staticText
        searchFieldTrait.trait = .searchField
        keyboardKey.trait = .keyboardKey
    }
    
    lazy var allTraitsButtons: [TraitCheckBox] = [
        buttonTrait,
        selectedTrait,
        disabledTrait,
        switcher,
        linkTrait,
        imageTrait,
        
        updatesFrequently,
        summaryElementTrait,
        playSoundTrait,
        startMediaSession,
        allowsDirectInteractionTrait,
        causesPageTurn,
        
        headerTrait,
        textInput,
        isEditingText,
        staticTextTrait,
        searchFieldTrait,
        keyboardKey,
    ]
    
    func setup(from descr: A11yDescription) {
        for traitButton in allTraitsButtons {
            let isOn = descr.trait.contains(traitButton.trait)
            traitButton.state = isOn ? .on: .off
        }
    }
}
