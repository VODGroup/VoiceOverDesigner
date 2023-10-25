import SwiftUI
import Document

#if os(iOS)
public struct ElementSettingsEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var element: A11yDescription
    var deleteAction: () -> Void
    
    public init(element: A11yDescription, delete: @escaping () -> Void) {
        self.element = element
        self.deleteAction = delete
    }
    
    public var body: some View {
        NavigationView {
            ElementSettingsView(element: element)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(Text("Element"))
                
                .toolbar {
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
public struct ElementSettingsEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var element: A11yDescription
    var deleteAction: () -> Void
    
    public init(element: A11yDescription, delete: @escaping () -> Void) {
        self.element = element
        self.deleteAction = delete
    }
    
    public var body: some View {
        ScrollView {
            ElementSettingsView(element: element)
                .padding()
        }
        .navigationTitle(Text("Element"))
        .toolbar {
            EditorToolbar(dismiss: dismiss, delete: delete)
        }
    }
    
    private func delete() {
        deleteAction()
        dismiss()
    }
    

}
#endif


public struct ElementSettingsView: View {
    @ObservedObject var element: A11yDescription
    
    public init(element: A11yDescription) {
        self.element = element
    }
    
    public var body: some View {
        Form {
            Text(element.voiceOverTextAttributed(font: .preferredFont(forTextStyle: .largeTitle)))
            
            TextValue(title: "Label", value: $element.label)
            ValueView(value: $element.value, adjustableOptions: $element.adjustableOptions, traits: $element.trait)
            TraitsView(selection: $element.trait)
            
            CustomActionsView(selection: $element.customActions)
            CustomDescriptionView(selection: $element.customDescriptions)
            TextValue(title: "Hint", value: $element.hint)
            Toggle("Is accessible?", isOn: $element.isAccessibilityElement)
            
        }
    }
}









#if DEBUG
struct ElementSettingsView_Previews: PreviewProvider {
    static var previews: some View {
#if os(iOS)
        ElementSettingsEditorView(element: .empty(frame: .zero), delete: {})
        #endif
        
        #if os(macOS)
        NavigationView {
            Text("Example")
            ElementSettingsEditorView(element: .empty(frame: .zero), delete: {})
        }

        #endif
    }
}
#endif

