//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 21.08.2022.
//

import Foundation
import AppKit

class CustomDescriptionView: NSView {
    
    let container: CustomDescriptionBox

    let removeButton: NSButton
        
    weak var delegate: CustomDescriptionViewDelegate?
    

    var label: String {
        get {
            container.labelTextField.stringValue
        }
        set {
            container.labelTextField.stringValue = newValue
        }
    }
    
    var value: String {
        get {
            container.valueTextField.stringValue
        }
        set {
            container.valueTextField.stringValue = newValue
        }
    }
    
    
    override var intrinsicContentSize: NSSize {
        get {
            CGSize(width: NSView.noIntrinsicMetric, height: 120)
        }
        
        set {}
    }
    
    init() {
        
        
        container = CustomDescriptionBox()
        container.translatesAutoresizingMaskIntoConstraints = false

        removeButton = NSButton(title: "Remove", target: nil, action: nil)
        removeButton.bezelStyle = .inline
        
        super.init(frame: .zero)

        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        container.labelTextField.target = self
        container.labelTextField.action = #selector(updateLabel)
        
        container.valueTextField.target = self
        container.valueTextField.action = #selector(updateValue)
        
        
        removeButton.target = self
        removeButton.action = #selector(deleteSelf)
        
        
        addSubview(container)
        addSubview(removeButton)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            removeButton.bottomAnchor.constraint(equalTo: container.contentView!.topAnchor, constant: -5),
            removeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
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
