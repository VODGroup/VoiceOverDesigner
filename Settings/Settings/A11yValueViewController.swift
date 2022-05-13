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
        
        descr.adjustableOptions.options.append("")
        
        renderDescription()
    }
    
    @IBAction func isAdjustableDidChange(_ sender: NSButton) {
        let isAdjustable = sender.state == .on
        descr.isAdjustable = isAdjustable
        
        if isAdjustable {
            let currentValue = view().value.stringValue
            if !currentValue.isEmpty {
                descr.adjustableOptions.options.append(currentValue)
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
            descr.adjustableOptions.options.remove(at: index)
        }
        
        renderDescription()
    }
    
    func select(option: AdjustableOption) {
        if let index = view().index(of: option) {
            descr.adjustableOptions.currentIndex = index
        }
        
        descr.value = option.value // TODO: Should be on data's level
        
        // TODO: Move to render
        view().optionsStack.arrangedSubviews
            .compactMap { view in
                view as? AdjustableOption
            }.filter { anOption in
                anOption != option
            }.forEach { anOption in
                anOption.radioButton.state = .off
            }
        
        delegate?.updateText()
    }
    
    func update(option: AdjustableOption) {
        if let index = view().index(of: option) {
            descr.adjustableOptions.options[index] = option.text
        }
    }
}
