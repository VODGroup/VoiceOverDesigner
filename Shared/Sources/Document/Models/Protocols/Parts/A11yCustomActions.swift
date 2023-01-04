//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 07.08.2022.
//

import Foundation

// Would like to make A11yCustomAction with uuid for swiftUI or make separate model
public struct A11yCustomActions: Codable {
    
    
    public init(names: [String] = []) {
        self.names = names
    }
    
    
    public var names: [String]
    
    
    
    
    public mutating func addNewCustomAction(named action: String) {
        names.append(action)
    }
    
    public mutating func remove(at index: Int) {
        names.remove(at: index)
    }
    
    public mutating func update(at index: Int, with name: String) {
        names[index] = name
    }
    
    static var empty: Self {
        Self(names: [])
    }
}
