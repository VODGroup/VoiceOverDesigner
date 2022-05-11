//
//  AdjustableOption.swift
//  Settings
//
//  Created by Mikhail Rubanov on 11.05.2022.
//

import AppKit

class AdjustableOption: NSView {
    
    let radioButton: NSButton
    let textView: NSTextField
    let removeButton: NSButton
    
    let stackView: NSStackView
    
    init() {
        self.radioButton = NSButton(radioButtonWithTitle: "",
                                    target: nil, action: nil)
        self.textView = NSTextField()
        
        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(equalToConstant: 240)
        ])
        
        
        self.removeButton = NSButton(title: "Remove", target: nil, action: nil)
        removeButton.bezelStyle = .inline
        
        
        
        self.stackView = NSStackView(views: [radioButton, textView, removeButton])
        stackView.orientation = .horizontal
        stackView.distribution = .fill
        
        super.init(frame: .zero)
        
        addSubview(stackView)
    }
    
    override var intrinsicContentSize: NSSize {
        get {
            CGSize(width: NSView.noIntrinsicMetric, height: 24)
        }
        
        set {}
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

