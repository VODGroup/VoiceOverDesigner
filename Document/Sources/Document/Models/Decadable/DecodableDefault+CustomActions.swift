extension DecodableDefault {
    public typealias EmptyCustomActions = DecodableDefault.Wrapper<Sources.EmptyCustomActions>
}

extension DecodableDefault.Sources {
    public enum EmptyCustomActions: DecodableDefault.Source {
        public static var defaultValue: A11yCustomActions { .empty }
    }
}
