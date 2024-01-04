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
#elseif os(macOS)
public struct ContainerSettingsEditorView: View {
    @ObservedObject var container: A11yContainer
    var deleteSelf: () -> Void
    
    public init(container: A11yContainer, deleteSelf: @escaping () -> Void) {
        self.container = container
        self.deleteSelf = deleteSelf
    }
    
    public var body: some View {
        ScrollView {
            ContainerSettingsView(container: container, deleteSelf: deleteSelf)
                .padding()
        }
    }
}
#endif

struct ContainerSettingsView: View {
    @Environment(\.unlockedProductIds) private var unlockedProductIds
    @ObservedObject var container: A11yContainer
    var deleteSelf: () -> Void

    init(container: A11yContainer, deleteSelf: @escaping () -> Void) {
        self.container = container
        self.deleteSelf = deleteSelf
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(container.label)
                .font(.largeTitle)
        #if os(macOS)
            if !unlockedProductIds.contains(.textRecognition) {
                TextRecognitionOfferView()
            }
        #endif
        }.padding(.bottom, 16)
        
        Form {
            TextValue(title: "Label", value: $container.label)
            containerTypePicker
            navigationStylePicker
            optionsView
            HStack {
                Spacer()
                Button("Delete", role: .destructive, action: deleteSelf)
                // TODO: Add backspace shortcut
            }
        }
    }

    // TODO: Remove duplication
    private var containerTypePicker: some View {
        Picker("Type", selection: $container.containerType, content: {
            ForEach(A11yContainer.ContainerType.allCases) { type in
                Text(type.rawValue)
                    .tag(type)
            }
        })
        .pickerStyle(.segmented)
        .modify({ picker in
            if #available(iOS 17.0, macOS 14.0, *) {
                picker.controlSize(.extraLarge)
            } else {
                picker.controlSize(.large)
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
        .pickerStyle(.segmented)
        .modify({ picker in
            if #available(iOS 17.0, macOS 14.0, *) {
                picker.controlSize(.extraLarge)
            } else {
                picker.controlSize(.large)
            }
        })
    }
    
    private var optionsView: some View {
        Section(content: {
            Toggle("Trait buttons as adjustable", isOn: $container.treatButtonsAsAdjustable)
                .disabled(!container.canTraitAsAdjustable)
            Toggle("Modal view", isOn: $container.isModal)
            Toggle("Tab Section", isOn: $container.isTabTrait)
            Toggle("Enumerate elements", isOn: $container.isEnumerated)
        }, header: {
            SectionTitle("Options")
        })
    }
}

extension View {
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        return modifier(self)
    }
}

#Preview("Container without buttons") {
    let container = A11yContainer(elements: [], frame: .zero, label: "Container")
    
    return ContainerSettingsEditorView(container: container, deleteSelf: {})
        .frame(width: 400, height: 500)
}

#Preview("Container with buttons") {
    let button = A11yDescription(isAccessibilityElement: true, label: "Button 1", value: "", hint: "", trait: .button, frame: .zero, adjustableOptions: AdjustableOptions(options: []), customActions: A11yCustomActions())
    let container = A11yContainer(elements: [button, button], frame: .zero, label: "Container")
    
    return ContainerSettingsEditorView(container: container, deleteSelf: {})
        .frame(width: 400, height: 500)
}
