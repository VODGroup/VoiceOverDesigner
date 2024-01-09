import SwiftUI

public struct TextFieldOnSubmit: View {
    @State var label: String
    @Binding var value: String // Available outside
    
    @State var innerValue: String // Used only for drawing inside textField
    
    public init(_ label: String,
         text: Binding<String>
    ) {
        self.label = label
        self._value = text
        self.innerValue = text.wrappedValue
    }
    
    public var body: some View {
        TextField(label, text: $innerValue) // Update only text in textField
            .onSubmit {
                value = innerValue // Send event outside to redraw once
            }
    }
}
