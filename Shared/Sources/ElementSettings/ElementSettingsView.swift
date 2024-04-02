import SwiftUI
import Document
import CommonUI

public struct ElementSettingsEditorView: View {
    
    @ObservedObject var element: A11yDescription
    var deleteSelf: () -> Void
    
    public init(element: A11yDescription, deleteSelf: @escaping () -> Void) {
        self.element = element
        self.deleteSelf = deleteSelf
    }
    
    public var body: some View {
#if os(iOS) || os(visionOS)
        NavigationView {
            ElementSettingsView(element: element, deleteSelf: deleteSelf)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(Text("Element"))
                
                .toolbar {
                    EditorToolbar(dismiss: dismiss, delete: delete)
                }
        }
        .navigationViewStyle(.stack)
#elseif os(macOS)
        ScrollView {
            ElementSettingsView(element: element, deleteSelf: deleteSelf)
                .padding()
            
        }
#endif
    }
    
#if os(iOS) || os(visionOS)
    @Environment(\.dismiss) var dismiss
    private func delete() {
        deleteSelf()
        dismiss()
    }
#endif
}

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
        VStack(alignment: .leading, spacing: 24) {
            Text(element.voiceOverTextAttributed(font: .preferredFont(forTextStyle: .largeTitle)))
                .padding(.horizontal, 16)
                .accessibilityIdentifier("ResultLabel")
                
#if os(macOS)
            if !unlockedProductIds.contains(.textRecognition) {
                TextRecognitionOfferView()
            }
#endif
            
            Form {
                TextValue(
                    title: "Label",
                    value: $element.label
                )
                .padding(.bottom, 16)
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
                    .padding(.bottom, 16)
                
                Section {
                    TextFieldOnSubmit("Hint", text: $element.hint)
                }
                .padding(.bottom, 24)
                
                HStack {
                    Toggle("Accessible", isOn: $element.isAccessibilityElement)
                    Spacer()
                    Button("Delete", role: .destructive, action: deleteSelf)
                        .keyboardShortcut(.delete, modifiers: [])
                }
                
                Spacer()
            }
        }
        .padding(.bottom, 16)
    }
}

#Preview {
    Measure {
        ElementSettingsEditorView(element: .empty(frame: .zero), deleteSelf: {})
            .frame(width: 400, height: 1200)
    }
}

#Preview("Empty adjustable") {
    let element = A11yDescription(isAccessibilityElement: true, label: "Size", value: "", hint: "", trait: .adjustable, frame: .zero, adjustableOptions: AdjustableOptions(options: []), customActions: A11yCustomActions())
    
    return Measure {
        ElementSettingsEditorView(element: element,
                                  deleteSelf: {})
        .frame(width: 400, height: 1200)
    }
}

#Preview("Adjustable") {
    let element = A11yDescription(isAccessibilityElement: true, label: "Size", value: "", hint: "", trait: .adjustable, frame: .zero, adjustableOptions: AdjustableOptions(options: ["Small", "Medium", "Large"], currentIndex: 1), customActions: A11yCustomActions())
    
    
    return Measure {
        ElementSettingsEditorView(element: element,
                                         deleteSelf: {})
        .frame(width: 400, height: 1200)
        .textRecognitionResults(["Small", "Medium", "Lagre"])
    }
}
