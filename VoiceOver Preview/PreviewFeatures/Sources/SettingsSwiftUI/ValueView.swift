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
        .textFieldStyle(.roundedBorder)
    }
    
    
    func defaultView(value: Binding<String>) -> some View {
        TextField("Value", text: value)
            
    }
    
    
    func adjustableView(options: Binding<AdjustableOptions>) -> some View {
        VStack(alignment: .leading) {
            ForEach(options.wrappedValue.options.indices, id: \.self) { index in
                HStack {
                    TextField("", text: options.options[index])
                    Button(role: .destructive, action: {
                        options.wrappedValue.remove(at: index)
                    }, label: {
                        Image(systemName: "delete.left")
                    })
                }
                
            }
            Button("+ Add Value", action: {
                options.wrappedValue.add()
            })
            .buttonStyle(.bordered)
        }

    }
}
