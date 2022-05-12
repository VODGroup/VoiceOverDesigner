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
        
        view().value.stringValue = descr.value
    }
    
    @IBAction func valueDidChange(_ sender: NSTextField) {
        descr.value = sender.stringValue
        delegate?.updateText()
    }
    
    @IBAction func addAdjustable(_ sender: Any) {
        view().isAdjustableTrait.state = .on
        
        let option = AdjustableOption()
        option.delegate = self
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
    
    func view() -> A11yValueView {
        view as! A11yValueView
    }
}

extension A11yValueViewController: AdjustableOptionDelegate {
    func delete(option: AdjustableOption) {
        let index = view().optionsStack.arrangedSubviews.firstIndex(of: option)
        
        // - 1 // remove create button
        
        view().optionsStack.removeView(option)
        
        if option.radioButton.state == .on {
            // TODO: Select another one
        }
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
}
