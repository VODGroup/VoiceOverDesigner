import Foundation
import AppKit
import Document

public enum DetailsState: StateProtocol {
    public static func == (lhs: DetailsState, rhs: DetailsState) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.control(let lhs), .control(let rhs)):
            return lhs === rhs
        default:
            return false
        }
    }
    
    case empty
    case control(any AccessibilityView)
    
    public static var `default`: Self = .empty
}

public class SettingsStateViewController: StateViewController<DetailsState> {
    
    public var settingsDelegate: SettingsDelegate!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.stateFactory = { state in
            switch state {
            case .empty:
                return EmptyViewController.fromStoryboard()
                
            case .control(let model):
                if let container = model as? A11yContainer {
                    // TODO: Show container settings
                    return NSViewController()
                } else if let element = model as? A11yDescription {
                    let settings = SettingsViewController.fromStoryboard()
                    settings.presenter = SettingsPresenter(
                        model: element,
                        delegate: self.settingsDelegate)
                    return settings
                } else {
                    fatalError()
                }
            }
        }
    }
    
    public static func fromStoryboard() -> SettingsStateViewController {
        let storyboard = NSStoryboard(name: "SettingsStateViewController", bundle: .module)
        return storyboard.instantiateInitialController() as! SettingsStateViewController
    }
}
