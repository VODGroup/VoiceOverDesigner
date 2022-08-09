//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 07.08.2022.
//

import Foundation

public struct A11yCustomActions: Codable {
    
    
    public init(names: [String] = []) {
        self.names = names
        
    }
    
    
    public private(set) var names: [String]
    
    
    public mutating func addNewCustomAction(named action: String) {
        names.append(action)
    }
    
    public mutating func remove(at index: Int) {
        names.remove(at: index)
    }
}
