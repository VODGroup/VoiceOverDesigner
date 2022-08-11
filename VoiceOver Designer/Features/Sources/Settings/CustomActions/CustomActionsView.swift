//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 07.08.2022.
//

import Document
import AppKit



class CustomActionsView: NSView {
        
    @IBOutlet var sectionLabel: NSTextField!
    @IBOutlet var actionsStack: NSStackView!
    @IBOutlet var addNewCustomActionButton: NSButton!
    
    override var intrinsicContentSize: NSSize {
        get {
            return CGSize(width: NSView.noIntrinsicMetric, height: 300)
        }
        
        set {}
    }
    
    
    func render(descr: A11yDescription, delegate: CustomActionOptionViewDelegate) {
    
        // TODO: It looks unoptimal to remove all and draw again. Some cache can help
        removeAllOptions()
        for name in descr.customActions.names {
            addNewCustomAction(named: name, delegate: delegate)
    
        }

    }
    
    func index(of option: CustomActionOptionView) -> Int? {
        actionsStack.arrangedSubviews.firstIndex(of: option)
    }
    
    func removeAllOptions() {
        actionsStack
            .arrangedSubviews
            .dropLast() // Remove Add button
            .reversed()
            .forEach { $0.removeFromSuperview() }
    }
    
    func addNewCustomAction(named name: String, delegate: CustomActionOptionViewDelegate) {
        let actionView = CustomActionOptionView()
        actionView.textfield.stringValue = name
        
        actionView.delegate = delegate
        actionsStack.insertArrangedSubview(actionView, at: insertIndex)
        actionView.textfield.becomeFirstResponder()
    }
    
    private var insertIndex: Int {
        if actionsStack.arrangedSubviews.count == 1 { // Add button
            return 0
        } else {
            return actionsStack.arrangedSubviews.count - 1 // Before add button
        }
    }
    
}
