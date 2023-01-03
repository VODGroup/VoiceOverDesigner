import SwiftUI
import Document



public struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismissAction
    @ObservedObject var element: A11yDescription
    
    var deleteAction: () -> Void
    
    public init(element: A11yDescription, deleteAction: @escaping () -> Void) {
        self.element = element
        self.deleteAction = deleteAction
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(element.voiceOverText)
                    .font(.largeTitle)
                
                TextValue(title: "Label", value: $element.label)
                TextValue(title: "Value", value: $element.value)
                TraitsView(selection: $element.trait)
                
                Divider()
                
                CustomActionsView(selection: $element.customActions)
                CustomDescriptionView(selection: $element.customDescriptions)
                TextValue(title: "Hint", value: $element.hint)
                Toggle("Is accessible?", isOn: $element.isAccessibilityElement)
                
                Button(role: .destructive, action: delete, label: {
                    Text("Delete")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                
            }
            .padding()
        }
        
    }
    
    private func delete() {
        deleteAction()
        dismissAction()
    }
}

struct SectionTitle: View {
    
    let title: LocalizedStringKey
    
    init(_ title: LocalizedStringKey) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.headline)
    }
}

struct TextValue: View {
    
    let title: LocalizedStringKey
    @Binding var value: String
    
    
    public var body: some View {
        Section(content: {
            TextField(title, text: $value)
                .textFieldStyle(.roundedBorder)
        }, header: {
            SectionTitle(title)
        })
    }
}





struct CustomDescriptionView: View {
    
    @Binding var selection: A11yCustomDescriptions
    
    public var body: some View {
        
        Section(content: {
            VStack(alignment: .leading) {
                ForEach($selection.descriptions, id: \.value) { $customDescription in
                    GroupBox {
                        TextField("Label:", text: $customDescription.label)
                        TextField("Value:", text: $customDescription.value)
                    }
                }
            }
            Button("+ Add custom description") {
                selection.addNewCustomDescription(.empty)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
        }, header: {
            SectionTitle("Custom description")
        })
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(element: .empty(frame: .zero), deleteAction: {})
    }
}

