//
//  AdjustableOption.swift
//  Settings
//
//  Created by Mikhail Rubanov on 11.05.2022.
//

import AppKit

protocol AdjustableOptionViewDelegate: AnyObject {
    func delete(option: AdjustableOptionView)
    func select(option: AdjustableOptionView)
    func update(option: AdjustableOptionView)
}

class AdjustableOptionView: NSView {
    
    let radioButton: NSButton
    let textView: NSTextField
    let removeButton: NSButton
    
    let stackView: NSStackView
    
    weak var delegate: AdjustableOptionViewDelegate?
    
    var isOn: Bool {
        get {
            radioButton.state == .on
        }
        set {
            radioButton.state = newValue ? .on: .off
        }
    }
    
    var text: String {
        get {
            textView.stringValue
        }
        set {
            textView.stringValue = newValue
        }
    }
    
    init() {
        self.radioButton = NSButton(radioButtonWithTitle: "",
                                    target: nil, action: nil)
        self.textView = NSTextField()
        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(equalToConstant: 280)
        ])
        
        
        self.removeButton = NSButton(title: "-", target: nil, action: nil)
        removeButton.bezelStyle = .inline
        
        self.stackView = NSStackView(views: [radioButton, textView, removeButton])
        stackView.orientation = .horizontal
        stackView.distribution = .fill
        
        super.init(frame: .zero)
        
        radioButton.target = self
        radioButton.action = #selector(select)
        
        textView.target = self
        textView.action = #selector(updateText)
        
        removeButton.target = self
        removeButton.action = #selector(deleteSelf)
        
        addSubview(stackView)
    }
    
    @objc func deleteSelf() {
        delegate?.delete(option: self)
    }
    
    @objc func select() {
        delegate?.select(option: self)
    }
    
    @objc func updateText() {
        delegate?.update(option: self)
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
    
    var value: String {
        textView.stringValue
    }
}

