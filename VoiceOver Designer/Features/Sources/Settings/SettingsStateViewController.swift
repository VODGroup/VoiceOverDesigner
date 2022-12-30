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
    public var textRecognitionCoordinator: TextRecognitionCoordinator!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.stateFactory = { state in
            switch state {
            case .empty:
                return EmptyViewController.fromStoryboard()
                
            case .control(let element):
                let settings = ElementSettingsViewController.fromStoryboard()
                settings.presenter = ElementSettingsPresenter(
                    element: element,
                    delegate: self.settingsDelegate)
                
                self.recognizeText(for: element)
                
                let scrollViewController = ScrollViewController.fromStoryboard()
                scrollViewController.embed(settings)
                
                return scrollViewController
                
            case .container(let container):
                let containerSettings = ContainerSettingsViewController.fromStoryboard()
                containerSettings.presenter = ContainerSettingsPresenter(
                    container: container,
                    delegate: self.settingsDelegate)
                
                self.recognizeText(for: container)
                
                return containerSettings
            }
        }
    }
    
    public static func fromStoryboard() -> SettingsStateViewController {
        let storyboard = NSStoryboard(name: "SettingsStateViewController", bundle: .module)
        return storyboard.instantiateInitialController() as! SettingsStateViewController
    }
}

import TextRecognition
extension SettingsStateViewController {
    
    func recognizeText(for model: any AccessibilityView) {
        Task {
            guard let result = try? await textRecognitionCoordinator.recongizeText(for: model) 
            else {
                return // No result, it possible
            }
            
            print("Recognition results \(result.text)")
            updateTextRecognition(result)
        }
    }
    
    @MainActor
    private func updateTextRecognition(_ result: RecognitionResult) {
        guard isSameControlSelected(result) else { return }
        
        guard let currentController = textRecognitionReceiver() else {
            print("Not found TextRecogitionReceiver")
            return
        }
        
        currentController.presentTextRecognition(result.text)
    }
    
    private func textRecognitionReceiver() -> TextRecogitionReceiver? {
        if let receiver = currentController as? TextRecogitionReceiver {
            return receiver
        }
        
        if let scrollViewController = currentController as? ScrollViewController,
           let contentReceiver = scrollViewController.child as? TextRecogitionReceiver {
            return contentReceiver
        }
        
        return nil
    }
    
    private func isSameControlSelected(_ result: RecognitionResult?) -> Bool {
        switch state {
        case .container(let container):
            if let selectedContainer = result?.control as? A11yContainer {
                return container == selectedContainer
            }
        case .control(let element):
            if let selectedElement = result?.control as? A11yDescription {
                return element == selectedElement
            }
        case .empty:
            return false
        }
        
        return false
    }
}
