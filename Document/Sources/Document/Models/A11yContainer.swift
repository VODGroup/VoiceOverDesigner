//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 08.11.2022.
//

import Foundation

public class A11yContainer: Codable, AccessibilityContainer {
    public init(elements: [A11yDescription], frame: CGRect, label: String) {
        self.elements = elements
        self.frame = frame
        self.label = label
    }
    
    
    public static func ==(lhs: A11yContainer, rhs: A11yContainer) -> Bool {
        lhs.frame == rhs.frame && lhs.elements == rhs.elements && lhs.label == rhs.label
    }
    
    
    public var elements: [A11yDescription]
    public var frame: CGRect
    public var label: String
    public var type: AccessibilityViewType = .container
}

public enum A11yElement: Codable {
    case description(A11yDescription)
    case container(A11yContainer)
}
