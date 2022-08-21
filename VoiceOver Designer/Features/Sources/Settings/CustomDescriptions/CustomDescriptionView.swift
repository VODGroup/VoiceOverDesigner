//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 21.08.2022.
//

import Foundation
import AppKit

class CustomDescriptionView: NSView {
    
    let container: NSBox
    let labelTextField: NSTextField
    let valueTextField: NSTextField
    let removeButton: NSButton
    
    weak var delegate: CustomDescriptionViewDelegate?
    
    var label: String {
        get {
            labelTextField.stringValue
        }
        set {
            labelTextField.stringValue = newValue
        }
    }
    
    var value: String {
        get {
            valueTextField.stringValue
        }
        set {
            valueTextField.stringValue = newValue
        }
    }
    
    init() {
        labelTextField = NSTextField()
        valueTextField = NSTextField()
        container = NSBox()
        removeButton = NSButton(title: "Remove", target: nil, action: nil)
        [labelTextField, valueTextField].forEach(container.addSubview(_:))
        super.init(frame: .zero)
        addSubview(container)
        addSubview(removeButton)
       
        
        labelTextField.target = self
        labelTextField.action = #selector(updateLabel)
        
        valueTextField.target = self
        valueTextField.action = #selector(updateValue)
        
        removeButton.target = self
        removeButton.action = #selector(deleteSelf)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func updateLabel() {
        delegate?.didUpdateDescription(self)
    }
    
    @objc func updateValue() {
        delegate?.didUpdateDescription(self)
    }
    
    @objc func deleteSelf() {
        delegate?.didDeleted(self)
    }
}
