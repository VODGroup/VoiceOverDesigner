import SwiftUI

public struct TextFieldOnSubmit: View {
    @State var label: String
    @Binding var value: String // Available outside
    
    @State var innerValue: String // Used only for drawing inside textField
    @FocusState private var isFocused: Bool
    public init(_ label: String,
         text: Binding<String>
    ) {
        self.label = label
        self._value = text
        self.innerValue = text.wrappedValue
    }
    
    public var body: some View {
        TextField(label, text: $innerValue) // Update only text in textField
            .focused($isFocused)
            .onChange(of: isFocused) { isFocused in
                publishChanges() // When set focus to another field
            }
            .onSubmit {
                publishChanges() // When press Enter
            }
            .onDisappear {
                publishChanges() // When user deselect accessibility element and hide settings screen
            }
    }
    
    func publishChanges() {
        value = innerValue // Send event outside to redraw once
    }
}
