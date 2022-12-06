//
//  SettingsViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import AppKit
import Document
import TextRecognition

public class SettingsViewController: NSViewController {

    public var presenter: SettingsPresenter!
    
    var descr: A11yDescription {
        presenter.model
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view().setup(from: descr)
    }
    
    func view() -> SettingsView {
        view as! SettingsView
    }
    
    weak var labelViewController: LabelViewController?
    weak var valueViewController: A11yValueViewController?
    weak var actionsViewController: CustomActionsViewController?
    weak var customDescriptionViewController: CustomDescriptionsViewController?
    
    public override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.destinationController {
        case let labelViewController as LabelViewController:
            self.labelViewController = labelViewController
            labelViewController.delegate = self
            labelViewController.view().labelText = descr.label
            
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
    
    // MARK: Text Recognition
    public func presentTextRecognition(_ alternatives: [String]) {
        print("Recognition results \(alternatives)")
        
        guard labelViewController?.view().isAutofillEnabled ?? false else { return }
        
        labelViewController?.presentTextRecognition(alternatives)
        valueViewController?.addTextRegognition(alternatives: alternatives)
    }
}

extension SettingsViewController: LabelDelegate {
    func updateLabel(to text: String) {
        presenter.updateLabel(to: text)
        updateTitle()
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
