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
    
    func render(descr: A11yDescription, delegate: CustomDescriptionViewDelegate) {
        
        // TODO: It looks unoptimal to remove all and draw again. Some cache can help
        removeAllOptions()
        
        for description in descr.customDescriptions.descriptions {
            addNewCustomDescription(for: description, delegate: delegate)
        }
    }
    
    func index(of option: CustomDescriptionView) -> Int? {
        descriptionsStack.arrangedSubviews.firstIndex(of: option)
    }
    
    func addNewCustomDescription(for description: A11yCustomDescription, delegate: CustomDescriptionViewDelegate) {
        let descriptionView = CustomDescriptionView()
        descriptionView.label = description.label
        descriptionView.delegate = delegate
        descriptionView.value = description.value
        descriptionView.container.title = "Description \(insertIndex)"
        
        descriptionsStack.insertArrangedSubview(descriptionView, at: insertIndex)
        descriptionView.container.labelTextField.becomeFirstResponder()
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
