import Document
import SwiftUI


public struct ContainerSettingsEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var container: A11yContainer
    var deleteAction: () -> Void
    
    public init(container: A11yContainer, delete: @escaping () -> Void) {
        self.container = container
        self.deleteAction = delete
    }
    
    @State private var isConfirmationDialogPresented = false
    
    
    public var body: some View {
        NavigationView {
            ContainerSettingsView(container: container)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(Text("Container"))
                .confirmationDialog("This control will be deleted from document",
                                    isPresented: $isConfirmationDialogPresented,
                                    titleVisibility: .visible,
                                    actions: confirmationDialogs)
                .toolbar {
                    // For some reason @Environment doesn't propagate to ToolbarContent
                    EditorToolbar(dismiss: dismiss, deleteTappedAction: {
                        isConfirmationDialogPresented = true
                    })
                }
        }
        .navigationViewStyle(.stack)
    }
    
    private func delete() {
        deleteAction()
        dismiss()
    }
    
    @ViewBuilder
    private func confirmationDialogs() -> some View {
        Button(role: .destructive, action: delete, label: {Text("Delete")})
        Button(role: .cancel, action: { isConfirmationDialogPresented = false }, label: {Text("Cancel")})
    }
}


public struct ContainerSettingsView: View {
    
    @ObservedObject var container: A11yContainer

    
    public init(container: A11yContainer) {
        self.container = container
    }
    
    public var body: some View {
        Form {
            Text(container.label)
                .font(.largeTitle)
            TextValue(title: "Label", value: $container.label)
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
        ContainerSettingsEditorView(container: .init(elements: [], frame: .zero, label: "er"), delete: {})
    }
}
#endif

