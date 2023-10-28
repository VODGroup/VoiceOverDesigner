import Document
import SwiftUI


struct ValueView: View {
    
    @Binding var value: String
    @Binding var adjustableOptions: AdjustableOptions
    @Binding var traits: A11yTraits
    
    var body: some View {
        Section(content: {
            if traits.contains(.adjustable) {
                adjustableView(options: $adjustableOptions)
            } else {
                defaultView(value: $value)
            }
            
        }, header: {
            HStack {
                SectionTitle("Value")
                Spacer()
                Toggle("Is Adjustable", isOn: $traits.bind(.adjustable))
                    .fixedSize()
            }  
        })
    }
    
    
    @ViewBuilder
    func defaultView(value: Binding<String>) -> some View {
        #if os(iOS)
        TextField("Value", text: value)
        #endif
        #if os(macOS)
        TextRecognitionComboBoxView(text: value)
        #endif
    }
    
    @ViewBuilder
    func adjustableView(options: Binding<AdjustableOptions>) -> some View {
        ForEach(options.wrappedValue.options.indices, id: \.self) { index in
            
            #if os(iOS)
            TextField("\(index)", text: options.options[index])
            #endif
            #if os(macOS)
            TextRecognitionComboBoxView(text: options.options[index])
            #endif
        }
        .onDelete(perform: { indexSet in
            options.wrappedValue.options.remove(atOffsets: indexSet)
        })
        Button(action: {
            options.wrappedValue.add()
        }, label: {
            Label("Add Value", systemImage: "plus")
        })

    }
}
