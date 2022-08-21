//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 21.08.2022.
//

import Foundation
import AppKit
import Document

class CustomDescriptionSectionView: NSView {
    @IBOutlet var sectionLabel: NSTextField!
    @IBOutlet var addNewCustomDescriptionButton: NSButton!
    @IBOutlet var descriptionsStack: NSStackView!
    
    override var intrinsicContentSize: NSSize {
        get {
            return CGSize(width: NSView.noIntrinsicMetric, height: 300)
        }
        
        set {}
    }
    
    func render(descr: A11yDescription) {
        
    }
    
    func index(of option: CustomDescriptionView) -> Int? {
        descriptionsStack.arrangedSubviews.firstIndex(of: option)
    }
    
    func addNewCustomDescription(for label: String, with value: String, delegate: CustomActionOptionViewDelegate) {
        let descriptionView = CustomDescriptionView()
        descriptionView.label = label
        descriptionView.value = value
        descriptionsStack.insertArrangedSubview(descriptionView, at: insertIndex)
        descriptionView.labelTextField.becomeFirstResponder()
    }
    
    func removeAllOptions() {
        descriptionsStack
            .arrangedSubviews
            .dropLast() // Remove Add button
            .reversed()
            .forEach { $0.removeFromSuperview() }
    }
    
    private var insertIndex: Int {
        if descriptionsStack.arrangedSubviews.count == 1 { // Add button
            return 0
        } else {
            return descriptionsStack.arrangedSubviews.count - 1 // Before add button
        }
    }
}
