//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 21.08.2022.
//

import Foundation

public struct A11yCustomDescriptions: Codable {
    public init(descriptions: [A11yCustomDescription] = []) {
        self.descriptions = descriptions
    }
    
    public private(set) var descriptions: [A11yCustomDescription]
    
    static var empty: A11yCustomDescriptions {
        A11yCustomDescriptions(descriptions: [])
    }
    
    public mutating func addNewCustomDescription(_ description: A11yCustomDescription) {
        descriptions.append(description)
    }
    
    public mutating func remove(at index: Int) {
        descriptions.remove(at: index)
    }
    
    public mutating func update(at index: Int, with description: A11yCustomDescription) {
        descriptions[index] = description
    }
}

extension A11yCustomDescriptions: DecodableDefaultSource {
    public static var defaultValue: A11yCustomDescriptions = .empty
}

public struct A11yCustomDescription: Codable {
    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    public var label: String
    public var value: String
    
    public static var empty: A11yCustomDescription {
        A11yCustomDescription(label: "", value: "")
    }
}
