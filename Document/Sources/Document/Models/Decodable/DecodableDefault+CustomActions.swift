extension DecodableDefault {
    public typealias EmptyCustomActions = DecodableDefault.Wrapper<Sources.EmptyCustomActions>
    public typealias EmptyCustomDescriptions = DecodableDefault.Wrapper<Sources.EmptyCustomDescriptions>
}

extension DecodableDefault.Sources {
    public enum EmptyCustomActions: DecodableDefault.Source {
        public static var defaultValue: A11yCustomActions { .empty }
    }
    
    public enum EmptyCustomDescriptions: DecodableDefault.Source {
        public static var defaultValue: A11yCustomDescriptions {.empty}
    }
}
