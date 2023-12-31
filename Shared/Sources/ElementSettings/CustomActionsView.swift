import Document
import SwiftUI

struct CustomActionsView: View {
    
    @Binding var selection: A11yCustomActions
    
    
    public var body: some View {
        
        Section(content: {
            
            ForEach(selection.names.indices, id: \.self) { index in
                HStack {
                    TextField("", text: $selection.names[index])
                    
                    #if os(macOS)
                    Button(action: {
                        selection.names.remove(at: index)
                    }, label: {
                        Image(systemName: "minus")
                    })
                    #endif
                    
                }
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
