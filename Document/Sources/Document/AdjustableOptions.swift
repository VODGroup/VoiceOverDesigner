//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 26.06.2022.
//

import Foundation

public struct AdjustableOptions: Codable {
    public init(
        options: [String],
        currentIndex: Int? = nil
    ) {
        self.options = options
        self.currentIndex = currentIndex
    }
    
    public private(set) var options: [String]
    public var currentIndex: Int?
    
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
        options[index] = text
    }
    
    public mutating func add(defaultValue: String = "") {
        options.append(defaultValue)
        
        if currentIndex == nil, options.count > 0 {
            self.currentIndex = 0
        }
    }
}
