import Foundation

class AccessibilityViewCodingService {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func data(from controls: [any AccessibilityView]) throws -> Data {
        let encodableWrapper = controls.map(AccessibilityViewDecodable.init(view:))
        
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(encodableWrapper)
        return data
    }
    
    func controls(from data: Data) throws -> [any AccessibilityView] {
        let controls = try decoder.decode([AccessibilityViewDecodable].self, from: data)
        
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
        let type = (try? container.decode(AccessibilityViewType.self, forKey: .type)) ?? .element // Default value is element
        
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
