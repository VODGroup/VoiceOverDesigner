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
    case frame(Frame)
    
    public static var `default`: Self = .empty
}

import Combine
public class SettingsStateViewController: StateViewController<DetailsState> {
    public var document: VODesignDocumentProtocol!
    public weak var settingsDelegate: SettingsDelegate!
    public var textRecognitionCoordinator: TextRecognitionCoordinator!
    
    lazy var textRecognitionUnlockPresenter = UnlockPresenter(
        productId: .textRecognition,
        unlockerDelegate: self)
    
    private var cancellables: Set<AnyCancellable> = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.stateFactory = { [weak self] state in
            guard let self = self else { fatalError() }
            
            switch state {
            case .empty:
                return NSHostingController(rootView: EmptySettingsView())
                
            case .control(let element):
                let elementView = ElementSettingsEditorView(element: element,
                                                            deleteSelf: { [weak self] in
                    self?.settingsDelegate.delete(model: element)
                })
                
                let containerViewController = HostingReceiverController(
                    content: { elementView },
                    unlocker: textRecognitionUnlockPresenter)
                self.recognizeText(for: element)
                
                observerElementChangesAndRedrawCanvasWhenChangesHappened(element)

                return containerViewController
            case .container(let container):
                
                let containerView = ContainerSettingsEditorView(container: container,
                                                                deleteSelf: { [weak self] in
                    self?.settingsDelegate.delete(model: container)
                })
                
                let containerViewController = HostingReceiverController(content: { containerView}, unlocker: textRecognitionUnlockPresenter)
                
                self.recognizeText(for: container)
                observerElementChangesAndRedrawCanvasWhenChangesHappened(container)
                
                return containerViewController
            case .frame(let frame):
                let frameSettings = FrameSettingsViewController(document: document, frame: frame, delegate: settingsDelegate)
                observerElementChangesAndRedrawCanvasWhenChangesHappened(frame)
                return frameSettings
            }
        }
    }
    
    func observerElementChangesAndRedrawCanvasWhenChangesHappened<T: ObservableObject>(
        _ element: T
    ) where T.ObjectWillChangePublisher == ObservableObjectPublisher  {
        element.objectWillChange.sink { _ in
            self.settingsDelegate.didUpdateElementSettings()
        }.store(in: &cancellables)
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
        case .frame, .empty:
            return
        }
    }
}

import TextRecognition
extension SettingsStateViewController {
    
    func recognizeText(for model: any ArtboardElement) {
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
        case .frame(let frame):
            if let selectedElement = result?.control as? Frame {
                return frame == selectedElement
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
    private let unlocker: UnlockPresenter
    
    init(
        @ViewBuilder content: () -> Content,
        unlocker: UnlockPresenter
    ) {
        self.content = content()
        self.unlocker = unlocker
        super.init(rootView: AnyView(content()))
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentTextRecognition(_ alternatives: [String]) {
        self.alternatives = alternatives
        rootView = AnyView(body)
    }
    
    func didChangeUnlockStatus(productId: Purchases.ProductId) {
        self.products.insert(productId)
        rootView = AnyView(body)
    }
    
    private var body: some View {
        content
            .textRecognitionResults(alternatives)
            .unlockedProductIds(products)
            .unlockPresenter(unlocker)
    }
}
