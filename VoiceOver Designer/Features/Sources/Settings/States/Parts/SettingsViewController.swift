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
        presenter.element
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad(ui: self)
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
            labelViewController.delegate = presenter
            labelViewController.view().labelText = descr.label
            
        case let valueViewController as A11yValueViewController:
            self.valueViewController = valueViewController
            valueViewController.presenter = presenter
            valueViewController.delegate = self // TODO: Delegate to presenter
            
        case let customActionViewController as CustomActionsViewController:
            actionsViewController = customActionViewController
            actionsViewController?.presenter = presenter
            
        case let traitsViewController as TraitsViewController:
            traitsViewController.delegate = presenter
            traitsViewController.view().setup(from: descr)
            
        case let customDescriptionsViewController as CustomDescriptionsViewController:
            customDescriptionViewController = customDescriptionsViewController
            customDescriptionViewController?.presenter = presenter
            
        default: break
        }
    }
    
    // MARK: Actions
    
    @IBAction func hintDidChange(_ sender: NSTextField) {
        presenter.changeHint(to: sender.stringValue)
    }
    
    @IBAction func delete(_ sender: Any) {
        presenter.delete()
    }
    
    @IBAction func isAccessibleElementDidChanged(_ sender: NSButton) {
        presenter.setIsAccessibleElement(sender.state == .on)
    }
    
    public static func fromStoryboard() -> SettingsViewController {
        let storyboard = NSStoryboard(name: "Settings", bundle: .module)
        return storyboard.instantiateInitialController() as! SettingsViewController
    }
}

// MARK: Text Recognition

extension SettingsViewController: TextRecogitionReceiver {
    
    public func presentTextRecognition(_ alternatives: [String]) {
        guard labelViewController?.view().isAutofillEnabled ?? false else { return }
        
        labelViewController?.presentTextRecognition(alternatives)
        valueViewController?.addTextRegognition(alternatives: alternatives)
    }
}

extension SettingsViewController: A11yValueDelegate, SettingsUI {
    public func updateTitle() {
        view().updateTitle(from: descr)
    }
}

