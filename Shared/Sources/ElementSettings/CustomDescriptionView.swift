import Document
import SwiftUI
import CommonUI

struct CustomDescriptionView: View {
    
    @State var selection: A11yCustomDescriptions
    
    enum Field {
        case label
        case value
    }
    
    @FocusState private var focusedField: Field?
    
    public var body: some View {
        
        Section(content: {
            ForEach($selection.descriptions) { $customDescription in
                GroupBox(content: {
                    content(
                        label: $customDescription.label,
                        value: $customDescription.value)
                }, label: {
                    label(value: customDescription)
                })
            }
            .onDelete(perform: { indexSet in
                selection.descriptions.remove(atOffsets: indexSet)
            })
            .textFieldStyle(.roundedBorder)
            
            Button(action: {
                selection.addNewCustomDescription(.empty)
                focusedField = .label
            }, label: {
                Label("Add custom description", systemImage: "plus")
            })
        }, header: {
            SectionTitle("Custom description")
        })
    }
    
    @ViewBuilder
    private func content(
        label: Binding<String>,
        value: Binding<String>
    ) -> some View {
        TextFieldOnSubmit("Label:", text: label)
            .focused($focusedField, equals: .label)
            .submitLabel(.continue)
            .onSubmit {
                focusedField = .value // Move to next field
            }
        
        TextFieldOnSubmit("Value:", text: value)
            .focused($focusedField, equals: .value)
            .submitLabel(.done)
    }
    
    private func label(value: A11yCustomDescription) -> some View {
        HStack {
            let index = selection.descriptions.firstIndex(of: value).flatMap { $0 + 1 }
            Text("Description \(index ?? 0)")
            Spacer()
            Button(action: {
                selection.descriptions.removeAll(where: {$0 == value})
            }, label: {
                Text("Delete")
            })
        }
    }
}
