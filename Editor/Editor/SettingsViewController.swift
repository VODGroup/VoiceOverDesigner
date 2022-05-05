//
//  SettingsViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import AppKit
import Document

protocol SettingsDelegate: AnyObject {
    func didUpdateValue()
    func delete(control: A11yControl)
}

class TraitCheckBox: NSButton {
    var trait: A11yTraits!
}

class SettingsViewController: NSViewController {
    
    weak var delegate: SettingsDelegate?
    var control: A11yControl!
    
    var descr: A11yDescription {
        control.a11yDescription!
    }
    
    @IBOutlet weak var resultLabel: NSTextField!
    
    @IBOutlet weak var value: NSTextField!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var hint: NSTextField!
    
    // MARK: Type trait
    @IBOutlet weak var buttonTrait: TraitCheckBox!
    @IBOutlet weak var headerTrait: TraitCheckBox!
    @IBOutlet weak var adjustableTrait: TraitCheckBox!
    @IBOutlet weak var linkTrait: TraitCheckBox!
    @IBOutlet weak var staticTextTrait: TraitCheckBox!
    @IBOutlet weak var imageTrait: TraitCheckBox!
    @IBOutlet weak var searchFieldTrait: TraitCheckBox!
    @IBOutlet weak var tabTrait: TraitCheckBox!
    
    // MARK: behaviourTrait
    // TODO: Add
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.stringValue = descr.label
        value.stringValue = descr.value
        hint.stringValue  = descr.hint
        
        updateText()
        
        buttonTrait.trait = .button
        headerTrait.trait = .header
        adjustableTrait.trait = .adjustable
        linkTrait.trait = .link
        staticTextTrait.trait = .staticText
        imageTrait.trait = .image
        searchFieldTrait.trait = .searchField
        tabTrait.trait = .tab
        
        let allTraitsButtons: [TraitCheckBox] = [
            buttonTrait,
            headerTrait,
            adjustableTrait,
            linkTrait,
            staticTextTrait,
            imageTrait,
            searchFieldTrait,
            tabTrait
        ]
        
        for traitButton in allTraitsButtons {
            traitButton.state = descr.trait.contains(traitButton.trait) ? .on: .off
        }
    }
    
    @IBAction func traitDidChange(_ sender: TraitCheckBox) {
        let isOn = sender.state == .on
        
        if isOn {
            control.a11yDescription?.trait.formUnion(sender.trait)
        } else {
            control.a11yDescription?.trait.subtract(sender.trait)
        }
        updateText()
    }
    
    // MARK: Description
    @IBAction func labelDidChange(_ sender: NSTextField) {
        control.a11yDescription?.label = sender.stringValue
        updateText()
    }
    
    @IBAction func valueDidChange(_ sender: NSTextField) {
        control.a11yDescription?.value = sender.stringValue
        updateText()
    }
    
    @IBAction func hintDidChange(_ sender: NSTextField) {
        control.a11yDescription?.hint = sender.stringValue
        updateText()
    }
    
    private func updateText() {
        resultLabel.stringValue = control.a11yDescription?.voiceOverText ?? ""
    }
    
    @IBAction func delete(_ sender: Any) {
        delegate?.delete(control: control)
        dismiss(self)
    }
    
    @IBAction func doneDidPressed(_ sender: Any) {
        delegate?.didUpdateValue()
        dismiss(self)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        delegate?.didUpdateValue()
    }
    
    public static func fromStoryboard() -> SettingsViewController {
        let storyboard = NSStoryboard(name: "Editor", bundle: Bundle(for: SettingsViewController.self))
        return storyboard.instantiateController(withIdentifier: "settings") as! SettingsViewController
    }
}
