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
    }
    
    private func delete() {
        deleteAction()
    }
}
#endif


public struct ElementSettingsView: View {
    @Environment(\.unlockedProductIds) private var unlockedProductIds
    @ObservedObject var element: A11yDescription
    
    public init(element: A11yDescription) {
        self.element = element
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(element.voiceOverTextAttributed(font: .preferredFont(forTextStyle: .largeTitle)))
        #if os(macOS)
            if !unlockedProductIds.contains(.textRecognition) {
                TextRecognitionOfferView()
            }
        #endif
        }.padding(.bottom, 16)
        
        Form {
            TextValue(
                title: "Label",
                value: $element.label
            )
            
            ValueView(
                value: $element.value,
                adjustableOptions: $element.adjustableOptions,
                traits: $element.trait
            )
            TraitsView(selection: $element.trait)
            
            CustomActionsView(selection: $element.customActions)
            
            CustomDescriptionView(selection: $element.customDescriptions)
            
            Section {
                TextField("Hint", text: $element.hint)
            }.padding(.top, 16)
            
            Toggle("Is accessible", isOn: $element.isAccessibilityElement)
            
        }
    }
}

#Preview {
    ElementSettingsEditorView(element: .empty(frame: .zero), delete: {})
        .frame(width: 400, height: 1200)
}

#Preview("adjustable") {
    let element = A11yDescription(isAccessibilityElement: true, label: "Size", value: "", hint: "", trait: .adjustable, frame: .zero, adjustableOptions: AdjustableOptions(options: ["Small", "Medium", "Large"], currentIndex: 1), customActions: A11yCustomActions())
    
    return ElementSettingsEditorView(element: element,
                                     delete: {})
    .frame(width: 400, height: 1200)
}
