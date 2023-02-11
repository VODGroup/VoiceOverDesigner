//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 04.09.2022.
//

import Foundation
import AppKit

class CustomDescriptionBox: NSBox {
    let labelView: NSTextField
    let valueView: NSTextField
    let labelTextField: NSTextField
    let valueTextField: NSTextField
    
    
    override var intrinsicContentSize: NSSize {
        get {
            CGSize(width: NSView.noIntrinsicMetric, height: 90)
        }
        
        set {}
    }
    
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
        labelView = NSTextField()
        valueView = NSTextField()
        labelView.stringValue = "Label:"
        labelView.isEditable = false
        valueView.stringValue = "Value:"
        valueView.isEditable = false
        valueView.isBordered = false
        labelView.isBordered = false
    
        labelView.backgroundColor = .clear
        valueView.backgroundColor = .clear
        
        labelTextField = NSTextField()
        labelTextField.bezelStyle = .roundedBezel
        labelTextField.cell?.sendsActionOnEndEditing = true
        valueTextField = NSTextField()
        valueTextField.bezelStyle = .roundedBezel
        valueTextField.cell?.sendsActionOnEndEditing = true
        labelTextField.isEditable = true
        valueTextField.isEditable = true
        
        super.init(frame: .zero)
        
        for view in [labelTextField, valueTextField, labelView, valueView] {
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            labelView.leadingAnchor.constraint(equalTo: contentView!.leadingAnchor, constant: 8),
            labelView.centerYAnchor.constraint(equalTo: labelTextField.centerYAnchor),
            valueView.leadingAnchor.constraint(equalTo: contentView!.leadingAnchor, constant: 8),
            valueView.centerYAnchor.constraint(equalTo: valueTextField.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            labelTextField.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 10),
            labelTextField.leadingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: 8),
            labelTextField.trailingAnchor.constraint(equalTo: contentView!.trailingAnchor, constant: -8),
            
            valueTextField.topAnchor.constraint(equalTo: labelTextField.bottomAnchor, constant: 10),
            valueTextField.leadingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: 8),
            valueTextField.trailingAnchor.constraint(equalTo: contentView!.trailingAnchor, constant: -8)
        ])
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
