import Document
import SwiftUI

struct TraitsView: View {
    
    @Binding var selection: A11yTraits
    
    init(selection: Binding<A11yTraits>) {
        self._selection = selection
    }
    
    public var body: some View {
        Section(content: {
            contentView(elements: Traits.type)
        }, header: {
            SectionTitle("Type Traits")
        })
        
        Section(content: {
            contentView(elements: Traits.behaviour)
        }, header: {
            SectionTitle("Behaviour Traits")
        })
        
        Section(content: {
            contentView(elements: Traits.text)
        }, header: {
            SectionTitle("Text Traits")
        })
    }
    
    
    private func traitsView(_ elements: [Traits]) -> some View {
        ForEach(elements) { trait in
            Toggle(trait.name, isOn: $selection.bind(trait.trait))
        }
    }
    
    
    private func contentView(elements: [Traits]) -> some View {
        
        #if os(macOS)
        VStack(alignment: .leading) {
            traitsView(elements)
        }
        .padding(.vertical)
        .toggleStyle(.checkbox)
        #else
        Group {
            if #available(iOS 16, macOS 13, *) {
                FlowLayout(spacing: 10) {
                    traitsView(elements)
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
        #endif
    }
}
