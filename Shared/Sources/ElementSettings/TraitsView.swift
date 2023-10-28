import Document
import SwiftUI

struct TraitsView: View {
    
    @Binding var selection: A11yTraits
    
    init(selection: Binding<A11yTraits>) {
        self._selection = selection
    }
    
    public var body: some View {
        Section(content: {
            flowView(elements: Traits.type)
        }, header: {
            SectionTitle("Type Traits")
        })
        
        Section(content: {
            flowView(elements: Traits.behaviour)
        }, header: {
            SectionTitle("Behaviour Traits")
        })
        
        Section(content: {
            flowView(elements: Traits.text)
        }, header: {
            SectionTitle("Text Traits")
        })
    }
    
    
    
    private func flowView(elements: [Traits]) -> some View {
        Group {
            if #available(iOS 16, macOS 13, *) {
                FlowLayout(spacing: 10) {
                    ForEach(elements) { trait in
                        Toggle(trait.name, isOn: $selection.bind(trait.trait))
                    }
                }
            } else {
                FlowView(elements: elements) { trait in
                    Toggle(trait.name, isOn: $selection.bind(trait.trait))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(.vertical)
        .toggleStyle(.button)
        .buttonStyle(.bordered)
    }
}
