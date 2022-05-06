//
//  SettingsViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import AppKit
import Document

public protocol SettingsDelegate: AnyObject {
    func didUpdateValue()
    func delete(control: A11yControl)
}

class TraitCheckBox: NSButton {
    var trait: A11yTraits!
}

public class SettingsPresenter {
    public init(
        control: A11yControl,
        delegate: SettingsDelegate
    ) {
        self.control = control
        self.delegate = delegate
    }
    
    public var control: A11yControl
    public weak var delegate: SettingsDelegate?
    
    func updateLabel(to newValue: String) {
        control.a11yDescription?.label = newValue
        control.updateColor()
    }
}

public class SettingsViewController: NSViewController {

    public var presenter: SettingsPresenter!
    
    var descr: A11yDescription {
        presenter.control.a11yDescription!
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
    
    public override func viewDidLoad() {
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
            descr.trait.formUnion(sender.trait)
        } else {
            descr.trait.subtract(sender.trait)
        }
        updateText()
    }
    
    // MARK: Description
    @IBAction func labelDidChange(_ sender: NSTextField) {
        // TODO: if you forgot to call updateColor, the label wouldn't be revalidated
        presenter.updateLabel(to: sender.stringValue)
        updateText()
    }
    
    @IBAction func valueDidChange(_ sender: NSTextField) {
        descr.value = sender.stringValue
        updateText()
    }
    
    @IBAction func hintDidChange(_ sender: NSTextField) {
        descr.hint = sender.stringValue
        updateText()
    }
    
    private func updateText() {
        resultLabel.stringValue = descr.voiceOverText ?? ""
    }
    
    @IBAction func delete(_ sender: Any) {
        presenter.delegate?.delete(control: presenter.control)
        dismiss(self)
    }
    
    @IBAction func doneDidPressed(_ sender: Any) {
        dismiss(self)
    }
    
    public override func viewWillDisappear() {
        super.viewWillDisappear()
        presenter.delegate?.didUpdateValue()
    }
    
    public static func fromStoryboard() -> SettingsViewController {
        let storyboard = NSStoryboard(name: "Settings", bundle: Bundle(for: SettingsViewController.self))
        return storyboard.instantiateController(withIdentifier: "settings") as! SettingsViewController
    }
}
