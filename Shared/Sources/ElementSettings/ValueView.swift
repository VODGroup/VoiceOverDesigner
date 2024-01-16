import Document
import SwiftUI
import CommonUI

struct ValueView: View {
    var element: A11yDescription
    
    // TODO: Use only `element`
    @Binding var value: String
    @Binding var adjustableOptions: AdjustableOptions
    @Binding var traits: A11yTraits
    
    var body: some View {
        LabeledContent {
            VStack(alignment: .leading) {
                Picker("Type", selection: element.adjustable(),
                       content: {
                    ForEach([
                        A11yTraits.StaticName,
                        A11yTraits.AdjustableName
                    ], id: \.self) { type in
                        Text(type)
                            .tag(type)
                    }
                })
                .pickerStyle(.segmented)
                .labelsHidden()

                if traits.contains(.adjustable) {
                    adjustableView(options: $adjustableOptions)
                } else {
                    defaultView(value: $value)
                }
            }.padding(.zero)
        } label: {
            Text("Value") // TODO: Align to right
        }
    }
    
    
    @ViewBuilder
    func defaultView(value: Binding<String>) -> some View {
        TextRecognitionComboBoxView(text: value)
            .accessibilityIdentifier("valueTextField")
    }
    
    @ViewBuilder
    func adjustableView(options: Binding<AdjustableOptions>) -> some View {
#if os(iOS) || os(visionOS)
        ForEach(options.wrappedValue.options.indices, id: \.self) { index in
            TextFieldOnSubmit("\(index)", text: options.options[index])
        }
        .onDelete(perform: { indexSet in
            options.wrappedValue.options.remove(atOffsets: indexSet)
        })
#elseif os(macOS)
        Picker(selection: options.currentIndex, content: {
            ForEach(options.wrappedValue.options.indices, id: \.self) { index in
                HStack {
                    TextRecognitionComboBoxView(text: options.options[index])
                        .accessibilityIdentifier("valueTextField-\(index)")
                    
                    Button(role: .destructive, action: {
                        options.wrappedValue.options.remove(at: index)
                    }, label: {
                        Image(systemName: "trash")
                    })
                }
                .tag(index as Int?)
                .buttonStyle(.borderless) // For trash buttons
            }
        }, label: EmptyView.init)
        .pickerStyle(.radioGroup)
        .offset(x: -27) // Align radio circles out of bounds
        .padding(.trailing, -27) // Add compensation to whole width
        .accessibilityIdentifier("AdjustableValues")
        .accessibilityElement(children: .contain)
#endif
        
        HStack {
            Button(action: {
                options.wrappedValue.add()
            }, label: {
                Label("Add Value", systemImage: "plus")
            }).controlSize(.large)

            Spacer()
            Toggle(isOn: options.isEnumerated) {
                Text("Enumerate")
            }
        }
    }
}

extension Binding where Value == A11yTraits {
    
    func adjustable() -> Binding<String> {
        return .init { () -> String in
            self.wrappedValue.contains(.adjustable) ? A11yTraits.AdjustableName : A11yTraits.StaticName
        } set: { newValue in
            if newValue == A11yTraits.AdjustableName {
                self.wrappedValue.insert(.adjustable)
            } else {
                self.wrappedValue.remove(.adjustable)
            }
        }
    }
}

extension A11yDescription {
    
    func adjustable() -> Binding<String> {
        return .init { () -> String in
            self.trait.contains(.adjustable) ? A11yTraits.AdjustableName : A11yTraits.StaticName
        } set: { newValue in
            if newValue == A11yTraits.AdjustableName {
                self.trait.insert(.adjustable)
                
                if self.adjustableOptions.options.isEmpty {
                    self.addAdjustableOption(defaultValue: self.value)
                }
            } else {
                self.trait.remove(.adjustable)
            }
        }
    }
}

#Preview("Static") {
    let options = AdjustableOptions(options: [])
    
    let element = A11yDescription(isAccessibilityElement: true, label: "Size", value: "", hint: "", trait: [], frame: .zero, adjustableOptions: options, customActions: A11yCustomActions())

    return ValueView(
        element: element,
        value: .constant("Text"),
        adjustableOptions: .constant(options),
        traits: .constant([])
    )
}

#Preview("Adjustable empty") {
    let options = AdjustableOptions(options: [])
    
    let element = A11yDescription(isAccessibilityElement: true, label: "Size", value: "", hint: "", trait: .adjustable, frame: .zero, adjustableOptions: options, customActions: A11yCustomActions())
    
    return ValueView(
        element: element,
        value: .constant("Text"),
        adjustableOptions: .constant(options),
        traits: .constant([.adjustable])
    )
}

#Preview("Adjustable sizes") {
    let options = AdjustableOptions(options: ["Small", "Meduim", "Large"])
    let element = A11yDescription(isAccessibilityElement: true, label: "Size", value: "", hint: "", trait: .adjustable, frame: .zero, adjustableOptions: options, customActions: A11yCustomActions())
    
    return ValueView(
        element: element,
        value: .constant("Text"),
        adjustableOptions: .constant(options),
        traits: .constant([.adjustable])
    )
}
