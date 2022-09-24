//
//  SettingsViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import AppKit
import Document

public class SettingsViewController: NSViewController {

    public var presenter: SettingsPresenter!
    
    var descr: A11yDescription {
        presenter.model
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view().setup(from: descr)
        view().isAutofillEnabled = settingStorage.isAutofillEnabled
    }
    
    private let settingStorage = SettingsStorage()
    
    func view() -> SettingsView {
        view as! SettingsView
    }
    
    weak var valueViewController: A11yValueViewController?
    weak var actionsViewController: CustomActionsViewController?
    weak var customDescriptionViewController: CustomDescriptionsViewController?
    
    public override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.destinationController {
        case let valueViewController as A11yValueViewController:
            self.valueViewController = valueViewController
            valueViewController.presenter = presenter
            valueViewController.delegate = self
        case let customActionViewController as CustomActionsViewController:
            actionsViewController = customActionViewController
            actionsViewController?.presenter = presenter
            
        case let traitsViewController as TraitsViewController:
            traitsViewController.delegate = self
            traitsViewController.view().setup(from: descr)
        case let customDescriptionsViewController as CustomDescriptionsViewController:
            customDescriptionViewController = customDescriptionsViewController
            customDescriptionViewController?.presenter = presenter
        default: break
        }
    }
    
    // MARK: Actions
    @IBAction func labelDidChange(_ sender: NSTextField) {
        // TODO: if you forgot to call updateColor, the label wouldn't be revalidated
        updateLabel(to: sender.stringValue)
    }
    
    private func updateLabel(to text: String) {
        presenter.updateLabel(to: text)
        updateTitle()
    }
    
    @IBAction func hintDidChange(_ sender: NSTextField) {
        descr.hint = sender.stringValue
        updateTitle()
    }
    
    @IBAction func delete(_ sender: Any) {
        presenter.delegate?.delete(model: presenter.model)
    }
    
    @IBAction func isAccessibleElementDidChanged(_ sender: NSButton) {
        descr.isAccessibilityElement = sender.state == .on
        presenter.delegate?.didUpdateValue()
    }
    
    public static func fromStoryboard() -> SettingsViewController {
        let storyboard = NSStoryboard(name: "Settings", bundle: .module)
        return storyboard.instantiateInitialController() as! SettingsViewController
    }
    
    @IBAction func isAutofillDidChanged(_ sender: NSButton) {
        settingStorage.isAutofillEnabled = sender.state == .on
    }
    
    // MARK: Text Recognition
    public func presentTextRecognition(_ alternatives: [String]) {
        print("Recognition results \(alternatives)")
        
        guard view().isAutofillEnabled else { return }
        
        view().label.addItems(withObjectValues: alternatives)
        valueViewController?.addTextRegognition(alternatives: alternatives)
        
        if view().labelText.isEmpty,
           let first = alternatives.first
        {
            view().labelText = first
            updateLabel(to: first)
        }
    }
}

extension SettingsViewController: A11yValueDelegate {
    func updateTitle() {
        view().updateText(from: descr)
        
        presenter.delegate?.didUpdateValue()
    }
}

extension SettingsViewController: TraitsViewControllerDelegate {
    func didChangeTrait(_ trait: A11yTraits, state: Bool) {
        if state {
            descr.trait.formUnion(trait)
        } else {
            descr.trait.subtract(trait)
        }
        updateTitle()
    }
}
