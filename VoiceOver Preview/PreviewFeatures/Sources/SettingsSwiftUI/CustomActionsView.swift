import Document
import SwiftUI

struct CustomActionsView: View {
    
    @Binding var selection: A11yCustomActions
    
    
    public var body: some View {
        
        Section(content: {
            
            VStack(alignment: .leading) {
                ForEach(selection.names.indices, id: \.self) { index in
                    
                    row(text: $selection.names[index], index: index)
                }
                .textFieldStyle(.roundedBorder)
                // Potentially could be onDelete(perform: IndexSet?)(but it works only in List
            }
            
            Button("+ Add custom action") {
                selection.addNewCustomAction(named: "")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
            
        }, header: {
            SectionTitle("Custom actions")
        })
    }
    
    private func row(text: Binding<String>, index: Int) -> some View {
        HStack {
            TextField("", text: text)
            if !text.wrappedValue.isEmpty {
                Button(role: .destructive, action: {
                    selection.names.remove(at: index)
                }, label: {
                    Image(systemName: "delete.left")
                })
            }
            
        }
    }
    
}
