extension DecodableDefault {
    public typealias EmptyCustomActions = DecodableDefault.Wrapper<Sources.EmptyCustomActions>
    public typealias EmptyCustomDescriptions = DecodableDefault.Wrapper<Sources.EmptyCustomDescriptions>
    public typealias ElementAccessibilityViewType = DecodableDefault.Wrapper<AccessibilityViewTypeDto>
    public typealias ContainerType = DecodableDefault.Wrapper<A11yContainer.ContainerType>
    public typealias NavigationStyle = DecodableDefault.Wrapper<A11yContainer.NavigationStyle>
}

extension DecodableDefault.Sources {
    public enum EmptyCustomActions: DecodableDefault.Source {
        public static var defaultValue: A11yCustomActions { .empty }
    }
    
    public enum EmptyCustomDescriptions: DecodableDefault.Source {
        public static var defaultValue: A11yCustomDescriptions {.empty}
    }
}


extension AccessibilityViewTypeDto: DecodableDefaultSource {
    public static var defaultValue: AccessibilityViewTypeDto = .element
}

extension A11yContainer.ContainerType: DecodableDefaultSource {
    public static var defaultValue: A11yContainer.ContainerType = .semanticGroup
}

extension A11yContainer.NavigationStyle: DecodableDefaultSource {
    public static var defaultValue: A11yContainer.NavigationStyle = .automatic
}
