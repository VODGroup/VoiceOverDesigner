import Foundation
import AppKit
import Document

public enum DetailsState: StateProtocol {
    case empty
    case control(A11yDescription)
    
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
                let settings = SettingsViewController.fromStoryboard()
                settings.presenter = SettingsPresenter(
                    model: model,
                    delegate: self.settingsDelegate)
                
                return settings
            }
        }
    }
    
    public static func fromStoryboard() -> SettingsStateViewController {
        let storyboard = NSStoryboard(name: "SettingsStateViewController", bundle: .module)
        return storyboard.instantiateInitialController() as! SettingsStateViewController
    }
}

//protocol Storyboardable {
//    public static func fromStoryboard() -> SettingsStateViewController {
//        let storyboard = NSStoryboard(name: String(description(for: Self)), bundle: .module)
//        return storyboard.instantiateInitialController() as! SettingsStateViewController
//    }
//}



