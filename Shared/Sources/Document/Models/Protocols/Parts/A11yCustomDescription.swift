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
    
    public var descriptions: [A11yCustomDescription]
    
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
        guard index < descriptions.count else {
            // When we delete item control lose focus, ends editing and sends data to delegate and crash.
            // Probably can be fixed on UI
            return
        }
        descriptions[index] = description
    }
}

extension A11yCustomDescriptions: DecodableDefaultSource {
    public static var defaultValue: A11yCustomDescriptions = .empty
}

public struct A11yCustomDescription: Equatable, Codable, Identifiable {
    public init(id: UUID = UUID(), label: String, value: String) {
        self.label = label
        self.value = value
        self.id = id
    }
    
    @DecodableDefault.RandomUUID
    public var id: UUID
    public var label: String
    public var value: String
    
    public static var empty: A11yCustomDescription {
        A11yCustomDescription(label: "", value: "")
    }
}
