import Foundation
import AppKit
import Document
import Purchases
import CommonUI
import ElementSettings
import SwiftUI

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
                return NSHostingController(rootView: EmptySettingsView())
                
            case .control(let element):
                
                
                let containerView = ElementSettingsEditorView(element: element,
                                                                delete: { [weak self] in
                    self?.settingsDelegate.delete(model: element)
                })
                    .unlockedProductAction { _ in
                        try? await self.textRecognitionUnlockPresenter.purchase()
                    }
                
                let containerViewController = HostingReceiverController { containerView }
                self.recognizeText(for: element)
                return containerViewController
            case .container(let container):
                
                let containerView = ContainerSettingsEditorView(container: container,
                                                                delete: { [weak self] in
                    self?.settingsDelegate.delete(model: container)
                })
                
                let containerViewController = HostingReceiverController { containerView }
                
                self.recognizeText(for: container)
                
                return containerViewController
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

extension SettingsStateViewController: PurchaseUnlockerDelegate {
    public func didChangeUnlockStatus(productId: ProductId) {
        if let unlockingController = purchaseUnlockingController() {
            unlockingController.didChangeUnlockStatus(productId: productId)
        }
        
        recognizeTextForCurrentModel()
    }
    
    private func recognizeTextForCurrentModel() {
        switch state {
        case .control(let element):
            recognizeText(for: element)
        case .container(let container):
            recognizeText(for: container)
        case .empty:
            return
        }
    }
}

import TextRecognition
extension SettingsStateViewController {
    
    func recognizeText(for model: any AccessibilityView) {
//        guard textRecognitionUnlockPresenter.isUnlocked() else { return }
        
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
    
    // MARK: - Controller traversion
    private func textRecognitionReceiver() -> TextRecogitionReceiver? {
        controller(ofType: TextRecogitionReceiver.self)
    }
    
    private func purchaseUnlockingController() -> PurchaseUnlockerDelegate? {
        controller(ofType: PurchaseUnlockerDelegate.self)
    }
    
    private func controller<SearchType>(ofType type: SearchType.Type) -> SearchType? {
        if let receiver = currentController as? SearchType {
            return receiver
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


final class HostingReceiverController<Content: View>: NSHostingController<AnyView>, TextRecogitionReceiver, PurchaseUnlockerDelegate {
    let content: Content
    
    private var alternatives: [String] = []
    private var products: Set<ProductId> = []
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        super.init(rootView: AnyView(content()))
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentTextRecognition(_ alternatives: [String]) {
        self.alternatives = alternatives
        rootView = AnyView(content.textRecognitionResults(alternatives).unlockedProductIds(products))
    }
    
    func didChangeUnlockStatus(productId: Purchases.ProductId) {
        self.products.insert(productId)
        rootView = AnyView(content.textRecognitionResults(alternatives).unlockedProductIds(products))
    }
}
