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

class TraitsView: NSView {
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
    @IBOutlet weak var allowsDirectInteractionTrait: TraitCheckBox!
    @IBOutlet weak var startMediaSession: TraitCheckBox!
    @IBOutlet weak var disabledTrait: TraitCheckBox!
    @IBOutlet weak var updatesFrequently: TraitCheckBox!
    @IBOutlet weak var causesPageTurn: TraitCheckBox!
    @IBOutlet weak var keyboardKey: TraitCheckBox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        allowsDirectInteractionTrait.trait = .allowsDirectInteraction
        startMediaSession.trait = .startsMediaSession
        disabledTrait.trait = .notEnabled
        updatesFrequently.trait = .updatesFrequently
        causesPageTurn.trait = .causesPageTurn
        keyboardKey.trait = .keyboardKey
    }
    
    lazy var allTraitsButtons: [TraitCheckBox] = [
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
        allowsDirectInteractionTrait,
        startMediaSession,
        disabledTrait,
        updatesFrequently,
        causesPageTurn,
        keyboardKey,
    ]
    
    func setup(from descr: A11yDescription) {
        for traitButton in allTraitsButtons {
            let isOn = descr.trait.contains(traitButton.trait)
            traitButton.state = isOn ? .on: .off
        }
    }
}
