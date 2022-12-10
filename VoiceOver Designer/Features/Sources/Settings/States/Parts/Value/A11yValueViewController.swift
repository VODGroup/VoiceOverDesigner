//
//  A11yValueViewController.swift
//  Settings
//
//  Created by Mikhail Rubanov on 07.05.2022.
//

import AppKit
import Document

protocol A11yValueDelegate: AnyObject {
    func updateTitle()
}

class A11yValueViewController: NSViewController {
    
    static func fromStoryboard() -> A11yValueViewController {
        let storyboard = NSStoryboard(
            name: "A11yValueViewController",
            bundle: .module)
        
        let controller = storyboard
            .instantiateInitialController() as! A11yValueViewController
        
        return controller
    }
    
    var presenter: SettingsPresenter!
    weak var delegate: A11yValueDelegate?
    
    var descr: A11yDescription {
        presenter.element
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderDescription(setFirstResponder: false)
    }
    
    @IBAction func valueDidChange(_ sender: NSTextField) {
        descr.value = sender.stringValue
        delegate?.updateTitle()
    }
    
    @IBAction func addAdjustable(_ sender: Any) {
        saveCurrentChanges()
        descr.addAdjustableOption()
        renderDescription(setFirstResponder: false)
        
        view().selectLastOption()
        
        delegate?.updateTitle()
    }
    
    func saveCurrentChanges() {
        if let currentOption = view().currentInputOption() {
            update(option: currentOption)
        }
    }
    
    @IBAction func isAdjustableDidChange(_ sender: NSButton) {
        let isAdjustable = sender.state == .on
        descr.isAdjustable = isAdjustable
        
        if isAdjustable {
            let currentValue = view().valueTextField.stringValue
            descr.addAdjustableOption(defaultValue: currentValue)
        }
        
        renderDescription(setFirstResponder: false)
        delegate?.updateTitle()
    }
    
    @IBAction func isEnumeratedDidChanged(_ sender: NSButton) {
        descr.isEnumeratedAdjustable = sender.state == .on
        
        delegate?.updateTitle()
    }
    
    func renderDescription(setFirstResponder: Bool) {
        view().render(descr: descr, delegate: self,
                      setFirstResponder: setFirstResponder,
                      alternatives: alternatives)
    }
    
    func view() -> A11yValueView {
        view as! A11yValueView
    }
   
    var alternatives: [String] = []
    func addTextRegognition(alternatives: [String]) {
        self.alternatives = alternatives
        
        view().valueTextField.addItems(withObjectValues: alternatives)
        view().optionViews.add(alternatives: alternatives)
    }
}

// MARK: - AdjustableOptionDelegate
extension A11yValueViewController: AdjustableOptionViewDelegate {
    func delete(option: AdjustableOptionView) {
        if let index = view().index(of: option) {
            descr.removeAdjustableOption(at: index)
        }
        renderDescription(setFirstResponder: true)
    }
    
    func select(option: AdjustableOptionView) {
        if let index = view().index(of: option) {
            descr.selectAdjustableOption(at: index)
        }
        
        view().deselectRadioGroup(selected: option)
        
        delegate?.updateTitle()
    }
    
    func update(option: AdjustableOptionView) {
        if let index = view().index(of: option) {
            descr.updateAdjustableOption(at: index,
                                           with: option.text)
        }
        
        delegate?.updateTitle()
    }
}
