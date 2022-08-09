//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 09.08.2022.
//

import AppKit


protocol CustomActionOptionViewDelegate: AnyObject {
    func delete(option: CustomActionOptionView)
    func update(option: CustomActionOptionView)
}

class CustomActionOptionView: NSView {
    let textfield: NSTextField
    let removeButton: NSButton
    let stackView: NSStackView
    
    
    weak var delegate: CustomActionOptionViewDelegate?
    
    init() {
        textfield = NSTextField()
        NSLayoutConstraint.activate([
            textfield.widthAnchor.constraint(equalToConstant: 280)
        ])
        removeButton = NSButton(title: "-", target: nil, action: nil)
        removeButton.bezelStyle = .inline
        stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.distribution = .fill
        super.init(frame: .zero)
        removeButton.action = #selector(deleteSelf)
        textfield.action = #selector(updateText)
        
    }
    
    @objc func deleteSelf() {
        delegate?.delete(option: self)
    }

    
    @objc func updateText() {
        delegate?.update(option: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
