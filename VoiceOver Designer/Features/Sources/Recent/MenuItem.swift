//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 12.02.2023.
//

import AppKit

/// A NSMenuItem subclass that accepts closure based action and invokes within it's selector
final class MenuItem: NSMenuItem {
    /// Provided closure to perform
    private var closure: () -> Void
    
    
    /// - returns: Returns an initialized instance of MenuItem.
    /// - parameters:
    ///     - title: The title of the menu item. This value must not be nil (if there is no title, specify an empty String)
    ///     - keyEquivalent: A string representing a keyboard key to be used as the key equivalent. This value must not be nil (if there is no key equivalent, specify an empty NSString).
    ///     - action: An action to perform on selector invoke
    init(title: String,
         keyEquivalent: String,
         action: @escaping () -> Void) {
        self.closure = action
        super.init(title: title, action: #selector(action(sender:)), keyEquivalent: keyEquivalent)
        self.target = self
    }
    
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// A selector action to invoke closure
    @objc private func action(sender: NSMenuItem) {
        closure()
    }
}
