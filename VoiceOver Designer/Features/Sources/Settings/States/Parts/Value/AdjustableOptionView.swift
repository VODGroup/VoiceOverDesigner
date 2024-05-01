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
    let textView: TextRecognitionComboBox
    let removeButton: NSButton
    
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
    
    var alternatives: [String] = [] {
        didSet {
            textView.addItems(withObjectValues: alternatives)
        }
    }
    
    init() {
        self.radioButton = NSButton(radioButtonWithTitle: "", target: nil, action: nil)
        self.textView = TextRecognitionComboBox()
        
        self.removeButton = NSButton(title: "-", target: nil, action: nil)
        removeButton.bezelStyle = .inline
        
        super.init(frame: .zero)
        
        addSubview(radioButton)
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        radioButton.target = self
        radioButton.action = #selector(select)
        
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.target = self
        textView.action = #selector(updateText)
        textView.cell?.sendsActionOnEndEditing = true
        
        addSubview(removeButton)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.target = self
        removeButton.action = #selector(deleteSelf)
        
        NSLayoutConstraint.activate([
            radioButton.widthAnchor.constraint(equalToConstant: 24.0),
            radioButton.topAnchor.constraint(equalTo: self.topAnchor),
            radioButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            radioButton.leftAnchor.constraint(equalTo: self.leftAnchor),
            
            textView.topAnchor.constraint(equalTo: self.topAnchor),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            textView.leftAnchor.constraint(equalTo: radioButton.rightAnchor, constant: 4.0),
            textView.rightAnchor.constraint(equalTo: removeButton.leftAnchor, constant: -4.0),
            
            removeButton.widthAnchor.constraint(equalToConstant: 24.0),
            removeButton.topAnchor.constraint(equalTo: self.topAnchor),
            removeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            removeButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -4.0)
        ])
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
    
    override func accessibilityLabel() -> String? {
        let label = textView.stringValue
        if label.isEmpty {
            return "Empty"
        } else {
            return label
        }
    }
    
    override func accessibilityValue() -> Any? {
        isOn ? "Selected": ""
    }
    
    override func accessibilityIdentifier() -> String {
        return "AdjustableOption"
    }
    
    override func isAccessibilityElement() -> Bool {
        return true
    }
}

extension AdjustableOptionView: NSComboBoxDelegate {
    func comboBoxSelectionDidChange(_ notification: Notification) {
        if let comboBox = notification.object as? NSComboBox {
            self.text = alternatives[comboBox.indexOfSelectedItem]
        }
        updateText()
    }
}

