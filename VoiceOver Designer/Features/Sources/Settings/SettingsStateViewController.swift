import Foundation
import AppKit
import Document
import Purchases

public enum DetailsState: StateProtocol {

    case empty
    case control(A11yDescription)
    case container(A11yContainer)
    
    public static var `default`: Self = .empty
}

public class SettingsStateViewController: StateViewController<DetailsState> {
    
    public weak var settingsDelegate: SettingsDelegate!
    public var textRecognitionCoordinator: TextRecognitionCoordinator!
    lazy var textRecognitionUnlockPresenter = UnlockPresenter(
        productId: .textRecognition,
        unlockerDelegate: self)
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.stateFactory = { [weak self] state in
            guard let self = self else { fatalError() }
            
            switch state {
            case .empty:
                return EmptyViewController.fromStoryboard()
                
            case .control(let element):
                let elementSettings = ElementSettingsViewController.fromStoryboard()
                elementSettings.presenter = ElementSettingsPresenter(
                    element: element,
                    delegate: self.settingsDelegate)
                elementSettings.textRecognitionUnlockPresenter = self.textRecognitionUnlockPresenter
                
                self.recognizeText(for: element)
                
                let scrollViewController = ScrollViewController.fromStoryboard()
                scrollViewController.embed(elementSettings)
                
                return scrollViewController
                
            case .container(let container):
                let containerSettings = ContainerSettingsViewController.fromStoryboard()
                containerSettings.presenter = ContainerSettingsPresenter(
                    container: container,
                    delegate: self.settingsDelegate)
                containerSettings.textRecognitionUnlockPresenter = self.textRecognitionUnlockPresenter
                
                self.recognizeText(for: container)
                
                return containerSettings
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        textRecognitionUnlockPresenter.prefetch()
    }
    
    public static func fromStoryboard() -> SettingsStateViewController {
        let storyboard = NSStoryboard(name: "SettingsStateViewController", bundle: .module)
        return storyboard.instantiateInitialController() as! SettingsStateViewController
    }
}

extension SettingsStateViewController: UnlockerDelegate {
    public func didChangeUnlockStatus(productId: ProductId) {
        if let unlockingController = purchaseUnlockingController() {
            unlockingController.didChangeUnlockStatus(productId: productId)
        }
    }
}

import TextRecognition
extension SettingsStateViewController {
    
    func recognizeText(for model: any AccessibilityView) {
        guard textRecognitionUnlockPresenter.isUnlocked() else { return }
        
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
        controller(ofType: TextRecogitionReceiver.self)
    }
    
    private func purchaseUnlockingController() -> UnlockerDelegate? {
        controller(ofType: UnlockerDelegate.self)
    }
    
    private func controller<SearchType>(ofType type: SearchType.Type) -> SearchType? {
        if let receiver = currentController as? SearchType {
            return receiver
        }
        
        if let scrollViewController = currentController as? ScrollViewController,
           let contentReceiver = scrollViewController.child as? SearchType {
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
