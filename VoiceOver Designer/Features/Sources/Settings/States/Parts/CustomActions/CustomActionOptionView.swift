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
        textfield.isEditable = true
        
        removeButton = NSButton(title: "-", target: nil, action: nil)
        removeButton.bezelStyle = .inline

        super.init(frame: .zero)
        
        addSubview(textfield)
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.target = self
        textfield.action = #selector(updateText)
        
        addSubview(removeButton)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.target = self
        removeButton.action = #selector(deleteSelf)
        
        NSLayoutConstraint.activate([
            textfield.topAnchor.constraint(equalTo: self.topAnchor),
            textfield.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            textfield.leftAnchor.constraint(equalTo: self.leftAnchor),
            textfield.rightAnchor.constraint(equalTo: removeButton.leftAnchor, constant: -4.0),
            
            removeButton.widthAnchor.constraint(equalToConstant: 24.0),
            removeButton.topAnchor.constraint(equalTo: self.topAnchor),
            removeButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -4.0),
            removeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
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
