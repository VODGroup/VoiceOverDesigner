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
    
    func render(descr: A11yDescription, delegate: AdjustableOptionDelegate) {
        value.stringValue = descr.value
        
        value.isEnabled = !descr.isAdjustable
        isAdjustableTrait.state = descr.isAdjustable ? .on: .off
        adjustableOptionsBox.isHidden = !descr.isAdjustable
        
        // TODO: It looks unoptimal to remove all and draw again. Some cache can help
        removeAllOptions()
        for (index, text) in descr.adjustableOptions.options.enumerated() {
            let option = addNewAdjustableOption(delegate: delegate, text: text)
            
            if index == descr.adjustableOptions.currentIndex {
                option.isOn = true
            }
        }
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
    ) -> AdjustableOption {
        let option = AdjustableOption()
        option.delegate = delegate
        option.text = text
        optionsStack.insertArrangedSubview(
            option,
            at: instertIndex)
        
        optionsStack.addArrangedSubview(option)
        
        option.textView.becomeFirstResponder()
        return option
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
