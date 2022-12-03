import CanvasAppKit
import Canvas

import TextUI
import Settings
import AppKit
import Document
import Combine

extension CanvasPresenter: TextBasedPresenter {}

class ProjectController: NSSplitViewController {
    
    init(document: VODesignDocument) {
        let canvasPresenter = CanvasPresenter(document: document)
        
        textContent = TextRepresentationController.fromStoryboard(
            document: document,
            presenter: canvasPresenter)
        
        canvas = CanvasViewController.fromStoryboard()
        canvas.inject(presenter: canvasPresenter)
        
        settings = SettingsStateViewController.fromStoryboard()
        
        super.init(nibName: nil, bundle: nil)
        
        settings.settingsDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let textContent: TextRepresentationController
    let canvas: CanvasViewController
    private let settings: SettingsStateViewController
    
    var document: VODesignDocument!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textSidebar = NSSplitViewItem(sidebarWithViewController: textContent)
        textSidebar.minimumThickness = 250
        textSidebar.allowsFullHeightLayout = true
        textSidebar.isSpringLoaded = true
        
        let settingsSidebar = NSSplitViewItem(sidebarWithViewController: settings)
        
        addSplitViewItem(textSidebar)
        addSplitViewItem(NSSplitViewItem(viewController: canvas))
        addSplitViewItem(settingsSidebar)
        
        canvas.presenter
            .selectedPublisher
            .sink(receiveValue: updateSelection(_:))
            .store(in: &cancellables)
        
        canvas.presenter
            .recognitionPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: updateTextRecognition(_:))
            .store(in: &cancellables)
    }
    
    private func updateTextRecognition(_ result: RecognitionResult?) {
        guard case .control(let model) = settings.state else { return }
        guard model === result?.control.model else { return }
        
        guard let currentController = settings.currentController as? SettingsViewController else { return }
       
        var alternatives = result?.text ?? []
        if alternatives.count > 1 {
            let combined = alternatives.joined(separator: " ")
            alternatives.append(combined)
        }
        currentController.presentTextRecognition(alternatives)
    }
}

// MARK: Settings visibility
extension ProjectController {
    private func updateSelection(_ selectedModel: (any AccessibilityView)?) {
        if let selectedModel = selectedModel {
            showSettings(for: selectedModel)
        } else {
            hideSettings()
        }
    }

    func showSettings(for model: any AccessibilityView) {
        switch model.cast {
        case .container(let container):
            settings.state = .container(container)
        case .element(let element):
            settings.state = .control(element)
        }
    }
    
    func hideSettings() {
        settings.state = .empty
    }
}

extension ProjectController: SettingsDelegate {
    public func didUpdateValue() {
        canvas.save()
    }
    
    public func delete(model: any AccessibilityView) {
        canvas.delete(model: model)
        settings.state = .empty
    }
}
