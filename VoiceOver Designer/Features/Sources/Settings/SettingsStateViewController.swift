import Foundation
import AppKit
import Document

public enum DetailsState: StateProtocol {

    case empty
    case control(A11yDescription)
    case container(A11yContainer)
    
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
                    element: model,
                    delegate: self.settingsDelegate)
                return settings
                
            case .container(let container):
                let containerSettings = ContainerSettingsViewController.fromStoryboard()
                containerSettings.presenter = ContainerSettingsPresenter(
                    container: container,
                    delegate: self.settingsDelegate)
                return containerSettings
            }
        }
    }
    
    public static func fromStoryboard() -> SettingsStateViewController {
        let storyboard = NSStoryboard(name: "SettingsStateViewController", bundle: .module)
        return storyboard.instantiateInitialController() as! SettingsStateViewController
    }
}
