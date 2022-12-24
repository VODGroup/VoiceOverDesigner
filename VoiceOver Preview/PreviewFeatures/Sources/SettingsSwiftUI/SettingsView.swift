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
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, idealHeight: 40)
                    
                })
                .buttonStyle(.borderedProminent)
                
                
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
    
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.headline)
    }
}

struct TextValue: View {
    
    let title: String
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

struct TraitsView: View {
    
    @Binding var selection: A11yTraits
    
    init(selection: Binding<A11yTraits>) {
        self._selection = selection
    }
    
    private var traits: [(String, A11yTraits)] = [("Button", .button), ("Header",.header), ("Link", .link), ("Static Text", .staticText), ("SearchField", .searchField)]
    
    public var body: some View {
        Section(content: {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(traits, id: \.0) { name, trait in
                        Toggle(name, isOn: $selection.bind(trait))
                    }
                }
            }
            .toggleStyle(.button)
            .buttonBorderShape(.capsule)
        }, header: {
            SectionTitle("Traits")
        })
        
        .frame(height: 40)
    }
}

struct CustomActionsView: View {
    
    @Binding var selection: A11yCustomActions
    
    public var body: some View {
        
        Section(content: {
            
            VStack(alignment: .leading) {
                ForEach($selection.names, id: \.self) { $name in
                    TextField("", text: $name)
                }
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

