import CanvasAppKit
import Canvas
import Navigator
import Settings
import AppKit
import Document
import Combine
import TextRecognition

extension CanvasPresenter: TextBasedPresenter {}

class ProjectController: NSSplitViewController {
    
    init(document: VODesignDocument, router: ProjectRouterDelegate) {
        self.router = router
        self.document = document
        
        let canvasPresenter = CanvasPresenter(document: document)
        
        navigator = NavigatorController.fromStoryboard(
            document: document,
            presenter: canvasPresenter)
        
        canvas = CanvasViewController.fromStoryboard()
        canvas.inject(presenter: canvasPresenter)
        
        settings = SettingsStateViewController.fromStoryboard()
        settings.textRecognitionCoordinator = TextRecognitionCoordinator(
            imageSource: canvas)
        
        super.init(nibName: nil, bundle: nil)
        
        settings.settingsDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let navigator: NavigatorController
    let canvas: CanvasViewController
    private let settings: SettingsStateViewController
    private(set) weak var router: ProjectRouterDelegate?
    
    var document: VODesignDocument!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textSidebar = NSSplitViewItem(sidebarWithViewController: navigator)
        textSidebar.minimumThickness = 250
        textSidebar.allowsFullHeightLayout = true
        textSidebar.isSpringLoaded = true
        
        settings.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settings.view.widthAnchor.constraint(equalToConstant: 400),
        ])
        let settingsSidebar = NSSplitViewItem(viewController: settings)
        
        addSplitViewItem(textSidebar)
        addSplitViewItem(NSSplitViewItem(viewController: canvas))
        addSplitViewItem(settingsSidebar)
        
        canvas.presenter
            .selectedPublisher
            .sink(receiveValue: updateSelection(_:))
            .store(in: &cancellables)
    }
    
    public var toolbar: NSToolbar {
        let toolbar: NSToolbar = NSToolbar()
        toolbar.delegate = self
        return toolbar
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
    public func updateValue() {
        canvas.publishControlChanges()
    }
    
    public func delete(model: any AccessibilityView) {
        canvas.delete(model: model)
        settings.state = .empty
    }
}

extension CanvasViewController: RecognitionImageSource {}
