import Foundation

class ArtboardElementCodingService {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func data(from artboard: Artboard) throws -> Data {
        let encodableWrapper = DocumentWrapper(artboard: artboard)
        
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(encodableWrapper)
        return data
    }
    
    func controls(from data: Data) throws -> [any ArtboardElement] {
        let controls = try decoder.decode([ArtboardElementDecodable].self, from: data)
        
        return controls.map(\.view)
    }
    
    func artboard(from data: Data) throws -> Artboard {
        let wrapper = try decoder.decode(DocumentWrapper.self, from: data)
        
        let artboard = Artboard(
            elements: wrapper.elements.map(\.view)
        )
            
        return artboard
    }
}

class DocumentWrapper: Codable {
    init(artboard: Artboard) {
        self.elements = artboard.elements.map({ frame in
            ArtboardElementDecodable(view: frame)
        })
    }
    
    public var elements: [ArtboardElementDecodable]
}

class ArtboardElementDecodable: Codable {
    init(view: any ArtboardElement) {
        self.view = view
    }
    
    var view: any ArtboardElement
    
    // MARK: Codable
    enum CodingKeys: CodingKey {
        case type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = (try? container.decode(ArtboardType.self, forKey: .type)) ?? .element // Default value is element
        
        switch type {
        case .frame:
            // TODO: Implement
            let dto = try FrameDTO(from: decoder)
            self.view = Frame(label: dto.label,
                              imageLocation: .from(dto: dto.imageLocation),
                              frame: dto.frame,
                              elements: dto.elements.map(\.view))
        case .element:
            self.view = try A11yDescription(from: decoder)
        case .container:
            self.view = try A11yContainer(from: decoder)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        switch view.cast {
        case .frame(let frame):
            try FrameDTO(frame: frame).encode(to: encoder)
        case .element(let element):
            try element.encode(to: encoder)
        case .container(let container):
            try container.encode(to: encoder)
        }
    }
}

class FrameDTO: Codable {
    init(frame: Frame) {
        self.label = frame.label
        self.frame = frame.frame
        self.imageLocation = .from(frame.imageLocation)
        self.elements = frame.elements.map(ArtboardElementDecodable.init(view:))
        
        self.id = frame.id
    }
    
    public var type: ArtboardType = .frame
    @DecodableDefault.RandomUUID
    public var id: UUID
    public var label: String
    public var imageLocation: ImageLocationDto
    public var frame: CGRect
    public var elements: [ArtboardElementDecodable]
}
