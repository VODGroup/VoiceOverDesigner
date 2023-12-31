//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 28.10.2023.
//

import Foundation
import SwiftUI

@available(macOS 12, *)
@available(iOS, unavailable)
public struct TextRecognitionComboBoxView: NSViewRepresentable {
    @Binding var text: String
    
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, text: $text)
    }
    
    public func makeNSView(context: Context) -> NSComboBox {
        let comboBox = NSComboBox()
        comboBox.isAutomaticTextCompletionEnabled = true
        comboBox.bezelStyle = .roundedBezel
        comboBox.isEditable = true
        comboBox.delegate = context.coordinator
        
        return comboBox
    }
    
    public func updateNSView(_ nsView: NSComboBox, context: Context) {
        nsView.removeAllItems()
        nsView.addItems(withObjectValues: context.environment.textRecognitionResults)
        
        // ComboBox doesn't automatically select the item matching its text; we must do that manually. But we need the delegate to ignore that selection-change or we'll get a "state modified during view update; will cause undefined behavior" warning.
        context.coordinator.ignoresSelectionChanges = true
        nsView.stringValue = text
        nsView.selectItem(withObjectValue: text)
        context.coordinator.ignoresSelectionChanges = false
    }
    
    @available(macOS 12, *)
    @available(iOS, unavailable)
    final public class Coordinator: NSObject, NSComboBoxDelegate {
        var parent: TextRecognitionComboBoxView
        var ignoresSelectionChanges: Bool = false
        var text: Binding<String>
        
        init(parent: TextRecognitionComboBoxView, text: Binding<String>) {
            self.parent = parent
            self.text = text
        }
        
        public func comboBoxSelectionDidChange(_ notification: Notification) {
            guard !ignoresSelectionChanges else { return }
            guard let comboBox = notification.object as? NSComboBox else { return }
            guard let selectedValue = comboBox.objectValueOfSelectedItem as? String else { return }
            text.wrappedValue = selectedValue
        }
        
        public func controlTextDidEndEditing(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            text.wrappedValue = textField.stringValue
        }
    }
}
