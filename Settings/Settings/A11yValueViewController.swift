//
//  A11yValueViewController.swift
//  Settings
//
//  Created by Mikhail Rubanov on 07.05.2022.
//

import AppKit
import Document

protocol A11yValueDelegate: AnyObject {
    func updateText()
}

class A11yValueViewController: NSViewController {
    
    var presenter: SettingsPresenter!
    weak var delegate: A11yValueDelegate?
    
    var descr: A11yDescription {
        presenter.control.a11yDescription!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderDescription()
    }
    
    @IBAction func valueDidChange(_ sender: NSTextField) {
        descr.value = sender.stringValue
        delegate?.updateText()
    }
    
    @IBAction func addAdjustable(_ sender: Any) {
        // TODO: Finish current editing, otherwise current text can be lost
        descr.trait.formUnion(.adjustable)
        
        descr.adjustableOptions.append("")
        
        renderDescription()
    }
    
    @IBAction func isAdjustableDidChange(_ sender: NSButton) {
        let isAdjustable = sender.state == .on
        descr.isAdjustable = isAdjustable
        
        if isAdjustable {
            let currentValue = view().value.stringValue
            if !currentValue.isEmpty {
                descr.adjustableOptions.append(currentValue)
            }
        }
        
        renderDescription()
    }
    
    func renderDescription() {
        view().render(descr: descr, delegate: self)
    }
    
    func view() -> A11yValueView {
        view as! A11yValueView
    }
}

// MARK: - AdjustableOptionDelegate
extension A11yValueViewController: AdjustableOptionDelegate {
    func delete(option: AdjustableOption) {
        if let index = view().index(of: option) {
            descr.adjustableOptions.remove(at: index)
        }
        
        view().remove(option: option)
    }
    
    func select(option: AdjustableOption) {
        view().optionsStack.arrangedSubviews
            .compactMap { view in
                view as? AdjustableOption
            }.filter { anOption in
                anOption != option
            }.forEach { anOption in
                anOption.radioButton.state = .off
            }
        
        descr.value = option.value
        delegate?.updateText()
    }
    
    func update(option: AdjustableOption) {
        if let index = view().index(of: option) {
            descr.adjustableOptions[index] = option.text
        }
    }
}
