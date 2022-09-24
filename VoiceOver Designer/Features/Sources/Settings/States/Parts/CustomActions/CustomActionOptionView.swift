//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 09.08.2022.
//

import AppKit


protocol CustomActionOptionViewDelegate: AnyObject {
    func delete(action: CustomActionOptionView)
    func update(action: CustomActionOptionView)
}

class CustomActionOptionView: NSView {
    let textfield: NSTextField
    let removeButton: NSButton
    let stackView: NSStackView
    
    var name: String {
        get {
            textfield.stringValue
        }
        set {
            textfield.stringValue = newValue
        }
    }
    
    
    weak var delegate: CustomActionOptionViewDelegate?
    
    init() {
        textfield = NSTextField()
        textfield.bezelStyle = .roundedBezel
        NSLayoutConstraint.activate([
            textfield.widthAnchor.constraint(equalToConstant: 280)
        ])
        textfield.isEditable = true
        
        removeButton = NSButton(title: "-", target: nil, action: nil)
        removeButton.bezelStyle = .inline
        stackView = NSStackView(views: [textfield, removeButton])
        stackView.orientation = .horizontal
        stackView.distribution = .fill
        super.init(frame: .zero)
        removeButton.target = self
        removeButton.action = #selector(deleteSelf)
        
        textfield.target = self
        textfield.action = #selector(updateText)
        
        addSubview(stackView)
        
    }
    
    @objc func deleteSelf() {
        delegate?.delete(action: self)
    }

    
    @objc func updateText() {
        delegate?.update(action: self)
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
