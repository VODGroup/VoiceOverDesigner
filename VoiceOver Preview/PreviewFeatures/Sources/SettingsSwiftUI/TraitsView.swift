import Document
import SwiftUI

struct TraitsView: View {
    
    @Binding var selection: A11yTraits
    
    init(selection: Binding<A11yTraits>) {
        self._selection = selection
    }
    
    
    public var body: some View {
        Group {
            Section(content: {
                flowView(elements: Traits.type)
            }, header: {
                SectionTitle("Type Traits")
            })
            
            DisclosureGroup(content: {
                flowView(elements: Traits.behaviour)
                    .padding(.top)
            }, label: {
                SectionTitle("Behaviour Traits")
                    .accessibilityAddTraits(.isHeader)
            })
        }
    }
    
    
    
    private func flowView(elements: [Traits]) -> some View {
        Group {
            if #available(iOS 16, *) {
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
        .toggleStyle(.button)
        .buttonBorderShape(.capsule)
        .buttonStyle(.bordered)

    }
    
}






