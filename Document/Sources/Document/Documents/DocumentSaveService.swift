//
//  DocumentSaveService.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Foundation

class DocumentSaveService {
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    private let fileURL: URL
    
    func save(controls: [any AccessibilityView]) {
        let encodableWrapper = controls.map(AccessibilityViewDecodable.init(view:))
        let data = try! JSONEncoder().encode(encodableWrapper)
        try! data.write(to: fileURL)
    }
    
    func loadControls() throws -> [any AccessibilityView] {
        let data = try Data(contentsOf: fileURL)
        let controls = try JSONDecoder().decode([AccessibilityViewDecodable].self, from: data)
        
        return controls.map(\.view)
        
    }
}

class AccessibilityViewDecodable: Codable {
    init(view: any AccessibilityView) {
        self.view = view
    }
    
    var view: any AccessibilityView
    
    // MARK: Codable
    enum CodingKeys: CodingKey {
        case type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(AccessibilityViewType.self, forKey: .type)
        switch type {
        case .element:
            self.view = try A11yDescription(from: decoder)
        case .container:
            self.view = try A11yContainer(from: decoder)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        switch view.type {
        case .element:
            try (view as? A11yDescription).encode(to: encoder)
        case .container:
            try (view as? A11yContainer).encode(to: encoder)
        }
    }
}
