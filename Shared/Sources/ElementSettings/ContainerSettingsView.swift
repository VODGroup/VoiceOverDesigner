import Document
import SwiftUI


#if os(iOS)
public struct ContainerSettingsEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var container: A11yContainer
    var deleteAction: () -> Void
    
    public init(container: A11yContainer, delete: @escaping () -> Void) {
        self.container = container
        self.deleteAction = delete
    }
    
    public var body: some View {
        NavigationView {
            ContainerSettingsView(container: container)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(Text("Container"))
                .toolbar {
                    // For some reason @Environment doesn't propagate to ToolbarContent
                    EditorToolbar(dismiss: dismiss, delete: delete)
                }
        }
        .navigationViewStyle(.stack)
    }
    
    private func delete() {
        deleteAction()
        dismiss()
    }
}
#endif

#if os(macOS)
public struct ContainerSettingsEditorView: View {
    @ObservedObject var container: A11yContainer
    var deleteAction: () -> Void
    
    public init(container: A11yContainer, delete: @escaping () -> Void) {
        self.container = container
        self.deleteAction = delete
    }
    
    public var body: some View {
        ScrollView {
            ContainerSettingsView(container: container)
                .padding()
        }
    }
    
    private func delete() {
        deleteAction()
    }
}
#endif

struct ContainerSettingsView: View {
    
    @ObservedObject var container: A11yContainer

    
    init(container: A11yContainer) {
        self.container = container
    }
    
    var body: some View {
        Form {
            Text(container.label)
                .font(.largeTitle)
            
            #if os(iOS)
            TextValue(title: "Label", value: $container.label)
            #endif
            
            #if os(macOS)
            
            // TODO: Add label to form (probably LabeledContent, but it's only from macOS 13)
            TextRecognitionComboBoxView(text: $container.label)
            
            #endif
            
            
            containerTypePicker
            navigationStylePicker
            optionsView
        }
    }
    
    private var containerTypePicker: some View {
        Picker("Type", selection: $container.containerType, content: {
            ForEach(A11yContainer.ContainerType.allCases) { type in
                Text(type.rawValue)
                    .tag(type)
            }
        })
        
        
    }
    
    private var navigationStylePicker: some View {
        Picker("Navigation Style", selection: $container.navigationStyle, content: {
            ForEach(A11yContainer.NavigationStyle.allCases) { style in
                Text(style.rawValue)
                    .tag(style)
            }
        })
    }
    
    private var optionsView: some View {
        Section(content: {
            Toggle("Modal view", isOn: $container.isModal)
            Toggle("Tab Section", isOn: $container.isTabTrait)
            Toggle("Enumerate elements", isOn: $container.isEnumerated)
        }, header: {
            SectionTitle("Options")
        })
    }
}

#if DEBUG
struct ContainerSettingsView_Previews: PreviewProvider {
    static var previews: some View {
#if os(iOS)
        ContainerSettingsEditorView(container: .init(elements: [], frame: .zero, label: "Containeer"), delete: {})
        #endif
        
        #if os(macOS)
        NavigationView {
            Text("Example")
            ContainerSettingsEditorView(container: .init(elements: [], frame: .zero, label: "Container"), delete: {})
        }

        #endif
    }
}
#endif

