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
    var deleteSelf: () -> Void
    
    public init(element: A11yDescription, deleteSelf: @escaping () -> Void) {
        self.element = element
        self.deleteSelf = deleteSelf
    }
    
    public var body: some View {
        ScrollView {
            ElementSettingsView(element: element, deleteSelf: deleteSelf)
                .padding()
            
        }
    }
}
#endif


public struct ElementSettingsView: View {
    @Environment(\.unlockedProductIds) private var unlockedProductIds
    @ObservedObject var element: A11yDescription
    private var deleteSelf: () -> Void
    
    public init(
        element: A11yDescription,
        deleteSelf: @escaping () -> Void
    ) {
        self.element = element
        self.deleteSelf = deleteSelf
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(element.voiceOverTextAttributed(font: .preferredFont(forTextStyle: .largeTitle)))
                .accessibilityIdentifier("ResultLabel")
            
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
            ).padding(.bottom, 16)
                .accessibilityIdentifier("LabelTextField")
            
            ValueView(
                element: element,
                value: $element.value,
                adjustableOptions: $element.adjustableOptions,
                traits: $element.trait
            )
            
            TraitsView(selection: $element.trait)
            
            CustomActionsView(selection: $element.customActions)
            
            CustomDescriptionView(selection: $element.customDescriptions)
            
            Section {
                TextField("Hint", text: $element.hint)
            }
            .padding(.top, 16)
                .padding(.bottom, 24)
            
            HStack {
                Toggle("Accessible", isOn: $element.isAccessibilityElement)
                Spacer()
                Button("Delete", role: .destructive, action: deleteSelf)
                    // TODO: Add backspace shortcut
            }
        }
    }
}

#Preview {
    ElementSettingsEditorView(element: .empty(frame: .zero), deleteSelf: {})
        .frame(width: 400, height: 1200)
}

#Preview("Empty adjustable") {
    let element = A11yDescription(isAccessibilityElement: true, label: "Size", value: "", hint: "", trait: .adjustable, frame: .zero, adjustableOptions: AdjustableOptions(options: []), customActions: A11yCustomActions())
    
    return ElementSettingsEditorView(element: element,
                                     deleteSelf: {})
    .frame(width: 400, height: 1200)
}

import TextRecognition
#Preview("Adjustable") {
    let element = A11yDescription(isAccessibilityElement: true, label: "Size", value: "", hint: "", trait: .adjustable, frame: .zero, adjustableOptions: AdjustableOptions(options: ["Small", "Medium", "Large"], currentIndex: 1), customActions: A11yCustomActions())
    
    return ElementSettingsEditorView(element: element,
                                     deleteSelf: {})
    .frame(width: 400, height: 1200)
    .textRecognitionResults(["Small", "Medium", "Lagre"])
}
