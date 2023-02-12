//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 26.06.2022.
//

import Foundation

// TODO: Probably needer AdjustableOption struct

public struct AdjustableOptions: Codable {
    public init(
        options: [String],
        currentIndex: Int? = nil
    ) {
        self.options = options
        self.currentIndex = currentIndex
    }
    
    public var options: [String]
    public var currentIndex: Int?
    public var currentValue: String? {
        guard let currentIndex = currentIndex else {
            return nil
        }
        
        let value = options[currentIndex]
        
        if isEnumerated, options.count > 1 {
            let enumerated = Localization.enumerated(option: currentIndex + 1, of: options.count)
            return "\(value), \(enumerated)"
        }
        
        return value
    }
    
    @DecodableDefault.True
    public var isEnumerated: Bool
    
    public mutating func remove(at index: Int) {
        options.remove(at: index)
        
        if let currentIndex = currentIndex,
           options.count <= currentIndex
        {
            self.currentIndex = options.count - 1
        }
        
        if options.count == 0 {
            self.currentIndex = nil
        }
    }
    
    public mutating func update(at index: Int, text: String) {
        guard index < options.count else {
            // When we delete item control lose focus, ends editing and sends data to delegate and crash.
            // Probably can be fixed on UI
            return
        }
        options[index] = text
    }
    
    public mutating func add(defaultValue: String = "") {
        guard !options.contains(defaultValue) else { return }
        options.append(defaultValue)
        
        if currentIndex == nil, options.count > 0 {
            self.currentIndex = 0
        }
    }
    
    public var isEmpty: Bool {
        options.isEmpty
    }
    
    public mutating func accessibilityIncrement() {
        guard let currentIndex = currentIndex, currentIndex < options.count - 1 else {
            return
        }
        self.currentIndex = currentIndex + 1
    }
    
    public mutating func accessibilityDecrement() {
        guard let currentIndex = currentIndex, currentIndex > 0 else {
            return
        }
        self.currentIndex = currentIndex - 1
    }
}
