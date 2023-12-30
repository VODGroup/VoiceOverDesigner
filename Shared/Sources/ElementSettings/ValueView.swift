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
        #if os(macOS)
        Picker(selection: options.currentIndex, content: {
            ForEach(options.wrappedValue.options.indices, id: \.self) { index in
                HStack {
                    TextRecognitionComboBoxView(text: options.options[index])
                    Button(action: {
                        options.wrappedValue.options.remove(at: index)
                    }, label: {
                        Image(systemName: "minus")
                    })
                }
                .tag(index as Int?)
            }
        }, label: EmptyView.init)
        .pickerStyle(.radioGroup)
        #else
        ForEach(options.wrappedValue.options.indices, id: \.self) { index in

            TextField("\(index)", text: options.options[index])
        }
        .onDelete(perform: { indexSet in
            options.wrappedValue.options.remove(atOffsets: indexSet)
        })
        #endif
        
        HStack {
            Button(action: {
                options.wrappedValue.add()
            }, label: {
                Label("Add Value", systemImage: "plus")
            })
            Spacer()
            Toggle(isOn: options.isEnumerated) {
                Text("Is enumerated")
            }
        }
    }
}
