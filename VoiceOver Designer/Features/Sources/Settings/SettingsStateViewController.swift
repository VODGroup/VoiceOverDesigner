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
    
    private let swiftUISettings = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.stateFactory = { [weak self] state in
            guard let self = self else { fatalError() }
            
            switch state {
            case .empty:
                return EmptyViewController.fromStoryboard()
                
            case .control(let element):
                if swiftUISettings {
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
                } else {
                    let elementSettings = ElementSettingsViewController.fromStoryboard()
                    elementSettings.presenter = ElementSettingsPresenter(
                        element: element,
                        delegate: self.settingsDelegate)
                    elementSettings.textRecognitionUnlockPresenter = self.textRecognitionUnlockPresenter
                    
                    self.recognizeText(for: element)
                    
                    let scrollViewController = ScrollViewController.fromStoryboard()
                    scrollViewController.embed(elementSettings)
                    self.recognizeText(for: element)
                    
                    return scrollViewController
                }
            case .container(let container):
                if swiftUISettings {
                    let containerView = ContainerSettingsEditorView(container: container,
                                                                    deleteSelf: { [weak self] in
                        self?.settingsDelegate.delete(model: container)
                    })
                    
                    let containerViewController = HostingReceiverController(content: { containerView}, unlocker: textRecognitionUnlockPresenter)
                    
                    self.recognizeText(for: container)
                    observerElementChangesAndRedrawCanvasWhenChangesHappened(container)
                    return containerViewController
                } else {
                    let containerViewController = ContainerSettingsViewController.fromStoryboard()
                    containerViewController.presenter = ContainerSettingsPresenter(
                        container: container,
                        delegate: self.settingsDelegate)
                    containerViewController.textRecognitionUnlockPresenter = self.textRecognitionUnlockPresenter
                    self.recognizeText(for: container)
                    return containerViewController
                }
                
            case .frame(let frame):
                // Frame settings too simple to create freeze
                
                let frameSettings = FrameSettingsViewController(document: document, frame: frame, delegate: settingsDelegate)
                observerElementChangesAndRedrawCanvasWhenChangesHappened(frame)
                return frameSettings
            }
        }
    }
    
    func observerElementChangesAndRedrawCanvasWhenChangesHappened<T: ObservableObject>(
        _ element: T
    ) where T.ObjectWillChangePublisher == ObservableObjectPublisher  {
        element.objectWillChange
            .receive(on: RunLoop.main) // Redraw when value **did** change – on the next cycle. It sooo hacky
            .sink { [weak self] element in
                guard let self = self else { return }
                
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

final class HostingReceiverController<Content: SwiftUI.View>: NSHostingController<AnyView>, TextRecogitionReceiver, PurchaseUnlockerDelegate {
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
    
    private var body: some SwiftUI.View {
        content
            .textRecognitionResults(alternatives)
            .unlockedProductIds(products)
            .unlockPresenter(unlocker)
    }
}
