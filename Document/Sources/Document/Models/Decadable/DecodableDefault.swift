// https://www.swiftbysundell.com/tips/default-decoding-values/

public protocol DecodableDefaultSource {
    associatedtype Value: Decodable
    static var defaultValue: Value { get }
}

public enum DecodableDefault {}

extension DecodableDefault {
    @propertyWrapper
    public struct Wrapper<Source: DecodableDefaultSource> {
        public typealias Value = Source.Value
        public var wrappedValue = Source.defaultValue
        
        public init() {}
    }
}

extension DecodableDefault.Wrapper: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: DecodableDefault.Wrapper<T>.Type,
                   forKey key: Key) throws -> DecodableDefault.Wrapper<T> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

extension DecodableDefault {
    public typealias Source = DecodableDefaultSource
    public typealias List = Decodable & ExpressibleByArrayLiteral
    public typealias Map = Decodable & ExpressibleByDictionaryLiteral
    
    public enum Sources {
        public enum True: Source {
            public static var defaultValue: Bool { true }
        }
        
        public enum False: Source {
            public static var defaultValue: Bool { false }
        }
        
        public enum EmptyString: Source {
            public static var defaultValue: String { "" }
        }
        
        public enum EmptyList<T: List>: Source {
            public static var defaultValue: T { [] }
        }
        
        public enum EmptyMap<T: Map>: Source {
            public static var defaultValue: T { [:] }
        }
        
        public enum EmptyCustomActions: Source {
            public static var defaultValue: A11yCustomActions { .empty }
        }
    }
}

extension A11yCustomActions: DecodableDefaultSource {
    public static var defaultValue: A11yCustomActions = .empty
    
    public typealias Value = A11yCustomActions
}

extension DecodableDefault {
    public typealias True = Wrapper<Sources.True>
    public typealias False = Wrapper<Sources.False>
    public typealias EmptyString = Wrapper<Sources.EmptyString>
    public typealias EmptyList<T: List> = Wrapper<Sources.EmptyList<T>>
    public typealias EmptyMap<T: Map> = Wrapper<Sources.EmptyMap<T>>
    
    public typealias EmptyCustomActions = Wrapper<Sources.EmptyCustomActions>
}

extension DecodableDefault.Wrapper: Equatable where Value: Equatable {}
extension DecodableDefault.Wrapper: Hashable where Value: Hashable {}

extension DecodableDefault.Wrapper: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}
