extension DecodableDefault {
    public typealias EmptyCustomActions = DecodableDefault.Wrapper<Sources.EmptyCustomActions>
    public typealias EmptyCustomDescriptions = DecodableDefault.Wrapper<Sources.EmptyCustomDescriptions>
    public typealias ElementAccessibilityViewType = DecodableDefault.Wrapper<AccessibilityViewType>
}

extension DecodableDefault.Sources {
    public enum EmptyCustomActions: DecodableDefault.Source {
        public static var defaultValue: A11yCustomActions { .empty }
    }
    
    public enum EmptyCustomDescriptions: DecodableDefault.Source {
        public static var defaultValue: A11yCustomDescriptions {.empty}
    }
}


extension AccessibilityViewType: DecodableDefaultSource {
    public static var defaultValue: AccessibilityViewType = .element
}
