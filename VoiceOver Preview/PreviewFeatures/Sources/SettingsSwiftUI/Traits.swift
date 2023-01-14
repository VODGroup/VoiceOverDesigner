import Foundation
import Document

enum Traits: Identifiable {
    
    public var id: Self { self }
    public var trait: A11yTraits {
        switch self {
        case .button:
            return .button
        case .header:
            return .header
        case .adjustable:
            return .adjustable
        case .link:
            return .link
        case .staticText:
            return .staticText
        case .image:
            return .image
        case .searchField:
            return .searchField
        case .selected:
            return .selected
        case .notEnabled:
            return .notEnabled
        case .summaryElement:
            return .summaryElement
        case .playsSound:
            return .playsSound
        case .allowsDirectInteraction:
            return .allowsDirectInteraction
        case .startsMediaSession:
            return .startsMediaSession
        case .updatesFrequently:
            return .updatesFrequently
        case .causesPageTurn:
            return .causesPageTurn
        case .keyboardKey:
            return .keyboardKey
        case .switcher:
            return .switcher
        case .textInput:
            return .textInput
        case .isEditing:
            return .isEditingTextInput
        }
    }
    
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
        case .isEditing:
            return NSLocalizedString("Is editing", comment: "")
        }
    }
    // MARK: Type
    case button
    case switcher
    case adjustable
    case link
    case image
    
    // MARK: Behaviour
    case selected
    case notEnabled
    case summaryElement
    case playsSound
    case allowsDirectInteraction
    case startsMediaSession
    case updatesFrequently
    case causesPageTurn
    
    // MARK: Text Input
    case textInput
    case header
    case isEditing
    case staticText
    case searchField
    case keyboardKey
    
    static let type: [Traits] = [.button, .adjustable, .link,  .image,  .switcher,]
    
    static let text: [Traits] = [.textInput, .header, .isEditing, .staticText, .searchField, .keyboardKey,]
    
    static let behaviour: [Traits] = [.selected, .notEnabled, .summaryElement, .playsSound, .allowsDirectInteraction, .startsMediaSession, .causesPageTurn,]
}
