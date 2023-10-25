import Document
import SwiftUI

struct CustomDescriptionView: View {
    
    @Binding var selection: A11yCustomDescriptions
    
    public var body: some View {
        
        Section(content: {
            ForEach($selection.descriptions) { $customDescription in
                GroupBox(content: {
                    content(
                        label: $customDescription.label,
                        value: $customDescription.value)
                }, label: {
                    label(value: customDescription)
                }).textFieldStyle(.roundedBorder)
            }
            .onDelete(perform: { indexSet in
                selection.descriptions.remove(atOffsets: indexSet)
            })
            Button(action: {
                selection.addNewCustomDescription(.empty)
            }, label: {
                Label("Add custom description", systemImage: "plus")
            })
        }, header: {
            SectionTitle("Custom description")
        })
    }
    
    @ViewBuilder
    private func content(label: Binding<String>, value: Binding<String>) -> some View {
        TextField("Label", text: label)
        TextField("Value", text: value)
    }
    
    private func label(value: A11yCustomDescription) -> some View {
        HStack {
            let index = selection.descriptions.firstIndex(of: value)
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
