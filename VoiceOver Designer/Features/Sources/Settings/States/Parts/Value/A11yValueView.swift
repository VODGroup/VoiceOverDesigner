//
//  A11yValueView.swift
//  Settings
//
//  Created by Mikhail Rubanov on 14.05.2022.
//

import AppKit
import Document

class A11yValueView: NSView {
    
    @IBOutlet weak var isAdjustableTrait: TraitCheckBox!
    
    @IBOutlet weak var isEnumeratedCheckBox: NSButton!
    @IBOutlet weak var mainStack: NSStackView!
    @IBOutlet weak var optionsStack: NSStackView!
    
    @IBOutlet weak var valueTextField: TextRecognitionComboBox!

    override var intrinsicContentSize: NSSize {
        get {
            return CGSize(width: NSView.noIntrinsicMetric, height: 300)
        }
        
        set {}
    }
    
    private var isAdjustable: Bool = false {
        didSet {
            valueTextField.isHidden = isAdjustable
            isAdjustableTrait.state = isAdjustable ? .on: .off
            optionsStack.isHidden = !isAdjustable
        }
    }
    
    func render(
        descr: A11yDescription,
        delegate: AdjustableOptionViewDelegate,
        setFirstResponder: Bool,
        alternatives: [String]
    ) {
        valueTextField.stringValue = descr.value
        
        isAdjustable = descr.isAdjustable
        
        update(options: descr.adjustableOptions,
               delegate: delegate,
               setFirstResponder: setFirstResponder,
               alternatives: alternatives)
        
        isEnumeratedCheckBox.isHidden = descr.adjustableOptions.options.count <= 1
        isEnumeratedCheckBox.state = descr.isEnumeratedAdjustable ? .on : .off
    }
    
    private func update(
        options: AdjustableOptions,
        delegate: AdjustableOptionViewDelegate,
        setFirstResponder: Bool,
        alternatives: [String]
    ) {
        // TODO: It looks unoptimal to remove all and draw again. Some cache can help
        removeAllOptions()
        for (index, text) in options.options.enumerated() {
            let option = addNewAdjustableOption(delegate: delegate,
                                                text: text,
                                                alternatives: alternatives)
            
            if index == options.currentIndex {
                option.isOn = true
                
                if setFirstResponder {
                    option.textView.becomeFirstResponder()
                }
            }
        }
    }
    
    func remove(option: AdjustableOptionView) {
        optionsStack.removeView(option)
        
        if option.isOn {
            selectFirstOption()
        }
    }
    
    func selectFirstOption() {
        // TODO: Select another one
    }
    
    func index(of option: AdjustableOptionView) -> Int? {
        optionsStack.arrangedSubviews.firstIndex(of: option)
    }
    
    func currentInputOption() -> AdjustableOptionView? {
        optionsStack
            .arrangedSubviews
            .compactMap { view in
                view as? AdjustableOptionView
            }
            .first { option in
                option.textView.currentEditor() != nil
            }
    }
    
    func addNewAdjustableOption(
        delegate: AdjustableOptionViewDelegate,
        text: String,
        alternatives: [String]
    ) -> AdjustableOptionView {
        let option = AdjustableOptionView()
        option.delegate = delegate
        option.text = text
        option.alternatives = alternatives
        optionsStack.insertArrangedSubview(
            option,
            at: instertIndex)
        
//        option.textView.becomeFirstResponder()
        return option
    }
    
    func deselectRadioGroup(selected: AdjustableOptionView) {
        // TODO: Move to render
        optionViews
            .filter { option in
                option != selected
            }.forEach { anOption in
                anOption.radioButton.state = .off
            }
    }
    
    private var instertIndex: Int {
        if optionsStack.arrangedSubviews.count == 1 { // Add button
            return 0
        } else {
            return optionsStack.arrangedSubviews.count - 1 // Before add button
        }
    }
    
    func removeAllOptions() {
        optionViews
            .reversed()
            .forEach { $0.removeFromSuperview() }
    }
    
    var optionViews: [AdjustableOptionView] {
        optionsStack.arrangedSubviews
            .compactMap { view in
                view as? AdjustableOptionView
            }
    }
    
    func selectLastOption() {
        optionViews.last?.textView.becomeFirstResponder()
    }
}

extension Array where Element == AdjustableOptionView {
    func add(alternatives: [String]) {
        forEach { adjustableOption in
            adjustableOption.alternatives = alternatives
        }
    }
}
