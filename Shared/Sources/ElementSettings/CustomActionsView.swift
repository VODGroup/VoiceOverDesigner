import Document
import SwiftUI
import CommonUI

struct CustomActionsView: View {
    
    @Binding var selection: A11yCustomActions
    
    
    public var body: some View {
        
        Section(content: {
            
            ForEach(selection.names.indices, id: \.self) { index in
                HStack {
                    TextFieldOnSubmit("", text: $selection.names[index])
                        .submitLabel(.done)
                        .accessibilityIdentifier("Custom action")
                    
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
