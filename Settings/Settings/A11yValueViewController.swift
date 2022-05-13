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
        
        renderDescription()
    }
    
    func renderDescription() {
        render(desrc: descr)
    }
    
    func render(desrc: A11yDescription) {
        view().value.stringValue = descr.value
        
        view().isAdjustableTrait.state = descr.isAdjustable ? .on: .off
        view().adjustableOptionsBox.isHidden = !descr.isAdjustable
    
        // TODO: It looks unoptimal to remove all and draw again. Some cache can help
        view().removeAllOptions()
        for text in descr.adjustableOptions {
            view().addNewAdjustableOption(delegate: self, text: text)
        }
    }
    
    func view() -> A11yValueView {
        view as! A11yValueView
    }
}

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

class A11yValueView: NSView {
    
    @IBOutlet weak var isAdjustableTrait: TraitCheckBox!
    @IBOutlet weak var optionsStack: NSStackView!
    
    @IBOutlet weak var value: NSTextField!
    @IBOutlet weak var adjustableOptionsBox: NSBox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        adjustableOptionsBox.isHidden = true
    }
    
    override var intrinsicContentSize: NSSize {
        get {
            return CGSize(width: NSView.noIntrinsicMetric, height: 300)
        }
        
        set {}
    }
    
    func remove(option: AdjustableOption) {
        optionsStack.removeView(option)
        
        if option.isOn {
            selectFirstOption()
        }
    }
    
    func selectFirstOption() {
        // TODO: Select another one
    }
    
    func index(of option: AdjustableOption) -> Int? {
        guard let index = optionsStack.arrangedSubviews.firstIndex(of: option) // Remove first button
        else { return  nil }
            
        return index - 1
    }
    
    func addNewAdjustableOption(
        delegate: AdjustableOptionDelegate,
        text: String
    ) {
        let option = AdjustableOption()
        option.delegate = delegate
        option.text = text
        optionsStack.insertArrangedSubview(
            option,
            at: instertIndex)
        
        optionsStack.addArrangedSubview(option)
        
        if optionsStack.arrangedSubviews.count == 2 { // New one and add button
            option.radioButton.state = .on
        }
        option.textView.becomeFirstResponder()
    }
    
    
    private var instertIndex: Int {
        if optionsStack.arrangedSubviews.count == 1 { // Add button
            return 0
        } else {
            return optionsStack.arrangedSubviews.count - 2 // Before add button
        }
    }
    
    func removeAllOptions() {
        optionsStack
            .arrangedSubviews
            .dropFirst()
            .reversed()
            .forEach { $0.removeFromSuperview() }
    }
}
