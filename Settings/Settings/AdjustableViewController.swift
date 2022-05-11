//
//  AdjustableViewController.swift
//  Settings
//
//  Created by Mikhail Rubanov on 07.05.2022.
//

import AppKit

class AdjustableViewController: NSViewController {
    
    @IBAction func addAdjustable(_ sender: Any) {
        view().isAdjustableTrait.state = .on
        
        let option = AdjustableOption()
        view().optionsStack.insertArrangedSubview(
            option,
            at: instertIndex)
        
        view().optionsStack.addArrangedSubview(option)
        
        if view().optionsStack.arrangedSubviews.count == 2 { // New one and add button
            option.radioButton.state = .on
        }
        option.textView.becomeFirstResponder()
    }
    
    @IBAction func isAdjustableDidChange(_ sender: NSButton) {
        view().adjustableOptionsBox.isHidden = sender.state == .off
    }
    
    private var instertIndex: Int {
        if view().optionsStack.arrangedSubviews.count == 1 { // Add button
            return 0
        } else {
            return view().optionsStack.arrangedSubviews.count - 2 // Before add button
        }
    }
    
    func view() -> AdjustableView {
        view as! AdjustableView
    }
}

class AdjustableView: NSView {
    
    @IBOutlet weak var isAdjustableTrait: TraitCheckBox!
    @IBOutlet weak var optionsStack: NSStackView!
    
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
}
