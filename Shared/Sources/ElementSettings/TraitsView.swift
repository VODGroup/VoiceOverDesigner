import Document
import SwiftUI

struct TraitsView: View {
    
    @Binding var selection: A11yTraits
    
    init(selection: Binding<A11yTraits>) {
        self._selection = selection
    }
    
    @ViewBuilder
    func traitMenuItems() -> some View {
        Section("Type") {
            traitsView(A11yTraits.type)
        }
        
        Section("Behaviour") {
            traitsView(A11yTraits.behaviour)
        }
        
        Section("Text") {
            traitsView(A11yTraits.text1 + A11yTraits.text2)
        }
    }
    
    public var body: some View {
#if os(iOS) || os(visionOS)
        if selection.selected().isEmpty {
            Menu {
                traitMenuItems()
            } label: {
                Label("Add trait", systemImage: "plus")
            }
        } else {
            FlowLayout(spacing: 10) {
                ForEach(selection.selected(), id: \.self) { trait in
                    Menu(trait.name) {
                        traitMenuItems()
                    }.controlSize(.mini)
                }
                .buttonStyle(.bordered)
            }
        }
#elseif os(macOS)
        Section(content: {
            HStack(alignment: .top, spacing: 24) {
                contentView(A11yTraits.type)
                contentView(A11yTraits.behaviour)
            }
            .padding(.vertical, -12)
        }, header: {
            SectionTitle("Type Traits")
        })
        
        Section(content: {
            HStack(alignment: .top, spacing: 52) {
                contentView(A11yTraits.text1)
                contentView(A11yTraits.text2)
            }
            .padding(.vertical, -12)
        }, header: {
            SectionTitle("Text Traits")
        })
#endif
    }

    @available(iOS 14, *)
    private func traitsView(_ traits: [A11yTraits]) -> some View {
        ForEach(traits, id: \.self) { trait in
            Toggle(trait.name, isOn: $selection.bind(trait))
        }
    }
#if os(macOS)
    @available(macOS 12, *)
    private func contentView(_ traits: [A11yTraits]) -> some View {
        VStack(alignment: .leading) {
            traitsView(traits)
        }
        .padding(.vertical)
        .toggleStyle(.checkbox)
    }
#endif
}

extension A11yTraits {
    public var name: String {
        switch self {
        case .button:
            return NSLocalizedString("Button", comment: "")
        case .header:
            return NSLocalizedString("Header", comment: "")
        case .adjustable:
            return NSLocalizedString("Adjustable", comment: "")
        case .link:
            return NSLocalizedString("Link", comment: "")
        case .staticText:
            return NSLocalizedString("Static Text", comment: "")
        case .image:
            return NSLocalizedString("Image", comment: "")
        case .searchField:
            return NSLocalizedString("SearchField", comment: "")
        case .selected:
            return NSLocalizedString("Selected", comment: "")
        case .notEnabled:
            return NSLocalizedString("Not enabled", comment: "")
        case .summaryElement:
            return NSLocalizedString("Summary element", comment: "")
        case .playsSound:
            return NSLocalizedString("Plays sound", comment: "")
        case .allowsDirectInteraction:
            return NSLocalizedString("Allows direct interaction", comment: "")
        case .startsMediaSession:
            return NSLocalizedString("Starts media session", comment: "")
        case .updatesFrequently:
            return NSLocalizedString("Updates frequently", comment: "")
        case .causesPageTurn:
            return NSLocalizedString("Causes Page Turn", comment: "")
        case .keyboardKey:
            return NSLocalizedString("Keyboard key", comment: "")
        case .switcher:
            return NSLocalizedString("Switch button", comment: "")
        case .textInput:
            return NSLocalizedString("Text field", comment: "")
        case .isEditingTextInput:
            return NSLocalizedString("Is editing", comment: "")
        default:
            return "Unknown"
        }
    }
    
    static let all: [Self] = type + behaviour + text1 + text2
    
    static let type: [Self] = [.button, .selected, .notEnabled, .link,  .image,  .switcher,]
    static let behaviour: [Self] = [.updatesFrequently, .summaryElement, .playsSound, .allowsDirectInteraction, .startsMediaSession, .causesPageTurn,]
    
    static let text1: [Self] = [.textInput, .header, .isEditingTextInput]
    static let text2: [Self] = [.staticText, .searchField, .keyboardKey,]
}

extension OptionSet where Element == A11yTraits {
    func selected() -> [A11yTraits] {
        A11yTraits.all.filter(contains)
    }
}
