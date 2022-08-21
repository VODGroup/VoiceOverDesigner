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
    let labelView: NSTextField
    let valueView: NSTextField
    let labelTextField: NSTextField
    let valueTextField: NSTextField
    let removeButton: NSButton
    let stackView: NSStackView
    
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
    
    
    override var intrinsicContentSize: NSSize {
        get {
            CGSize(width: NSView.noIntrinsicMetric, height: 100)
        }
        
        set {}
    }
    
    init() {
        labelView = NSTextField()
        valueView = NSTextField()
        labelView.stringValue = "Label:"
        valueView.stringValue = "Value:"
        labelTextField = NSTextField()
        valueTextField = NSTextField()
        labelTextField.isEditable = true
        valueTextField.isEditable = true
        
        container = NSBox()
        removeButton = NSButton(title: "Remove", target: nil, action: nil)
        removeButton.bezelStyle = .inline


        
        stackView = NSStackView(views: [container, removeButton])
        stackView.orientation = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .top
        

        
        super.init(frame: .zero)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
        
        
        container.autoresizesSubviews = true

        for view in [labelTextField, valueTextField, labelView, valueView] {
            container.contentView?.addSubview(view)
        }
        
//        NSLayoutConstraint.activate([
//            labelView.topAnchor.constraint(equalTo: container.contentView!.topAnchor, constant: 8),
//            labelTextField.leadingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: 8),
//            valueView.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 8),
//            labelTextField.leadingAnchor.constraint(equalTo: valueView.trailingAnchor, constant: 8),
//        ])
//        
       
        
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
