import Document
import SwiftUI

struct CustomActionsView: View {
    
    @Binding var selection: A11yCustomActions
    
    
    public var body: some View {
        
        Section(content: {
            
            ForEach(selection.names.indices, id: \.self) { index in
                TextField("", text: $selection.names[index])
            }
            .onDelete(perform: { indexSet in
                selection.names.remove(atOffsets: indexSet)
            })
            
            Button(action: {
                selection.addNewCustomAction(named: "")
            }, label: {
                Label("Add custom action", systemImage: "plus")
            })
            
        }, header: {
            SectionTitle("Custom actions")
        })
    }
}
