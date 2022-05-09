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
        view().optionsStack.addArrangedSubview(option)
        
        // Enable
        option.radioButton.state = .on // TODO: Only first
        option.textView.becomeFirstResponder()
        
//        preferredContentSizeDidChange(for: self)
    }
    
    func view() -> AdjustableView {
        view as! AdjustableView
    }
}

class AdjustableOption: NSView {
    
    let radioButton: NSButton
    let textView: NSTextField
    let removeButton: NSButton
    
    let stackView: NSStackView
    
    init() {
        self.radioButton = NSButton(radioButtonWithTitle: "",
                                    target: nil, action: nil)
        self.textView = NSTextField()
        
        self.removeButton = NSButton(title: "Remove", target: nil, action: nil)
        removeButton.bezelStyle = .inline
        
        self.stackView = NSStackView(views: [radioButton, textView, removeButton])
    
        super.init(frame: .zero)
        
        addSubview(stackView)
    }
    
    override func layout() {
        super.layout()
        stackView.frame = bounds
    }
    
    override var intrinsicContentSize: NSSize {
        get {
            CGSize(width: NSView.noIntrinsicMetric, height: 24)
        }
        
        set {
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AdjustableView: NSView {
    
    @IBOutlet weak var isAdjustableTrait: TraitCheckBox!
    @IBOutlet weak var optionsStack: NSStackView!
}

