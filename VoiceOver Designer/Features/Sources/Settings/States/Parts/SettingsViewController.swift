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
    }
    
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
        presenter.updateLabel(to: sender.stringValue)
        updateText()
    }
    
    @IBAction func hintDidChange(_ sender: NSTextField) {
        descr.hint = sender.stringValue
        updateText()
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
}

extension SettingsViewController: A11yValueDelegate {
    func updateText() {
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
        updateText()
    }
}
