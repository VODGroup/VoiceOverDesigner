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
    
    static func fromStoryboard() -> A11yValueViewController {
        let storyboard = NSStoryboard(
            name: "A11yValueViewController",
            bundle: Bundle(for: A11yValueViewController.self))
        
        let controller = storyboard
            .instantiateInitialController() as! A11yValueViewController
        
        return controller
    }
    
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
        saveCurrentChanges()
        
        descr.trait.formUnion(.adjustable)
        
        descr.adjustableOptions.add()
        
        renderDescription()
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
            descr.adjustableOptions.add(defaultValue: currentValue)
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
extension A11yValueViewController: AdjustableOptionViewDelegate {
    func delete(option: AdjustableOptionView) {
        if let index = view().index(of: option) {
            descr.adjustableOptions.remove(at: index)
            if descr.adjustableOptions.isEmpty {
                descr.trait.remove(.adjustable)
            }
        }
        
        renderDescription()
    }
    
    func select(option: AdjustableOptionView) {
        if let index = view().index(of: option) {
            descr.adjustableOptions.currentIndex = index
        }
        
        descr.value = option.value // TODO: Should be on data's level
        
        // TODO: Move to render
        view().optionsStack.arrangedSubviews
            .compactMap { view in
                view as? AdjustableOptionView
            }.filter { anOption in
                anOption != option
            }.forEach { anOption in
                anOption.radioButton.state = .off
            }
        
        delegate?.updateText()
    }
    
    func update(option: AdjustableOptionView) {
        if let index = view().index(of: option) {
            descr.adjustableOptions.update(at: index,
                                           text: option.text)
        }
    }
}
