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
    
    init(
        document: VODesignDocument,
        router: ProjectRouterDelegate
    ) {
        self.router = router
        self.document = document
        
        let canvasPresenter = CanvasPresenter(document: document)
        
        navigator = NavigatorController.fromStoryboard(
            document: document,
            presenter: canvasPresenter)
        
        canvas = CanvasViewController.fromStoryboard()
        canvas.inject(presenter: canvasPresenter)
        
        settings = SettingsStateViewController.fromStoryboard()
        settings.document = document
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

    private lazy var textSidebar: NSSplitViewItem = {
        let textSidebar = NSSplitViewItem(sidebarWithViewController: navigator)
        textSidebar.minimumThickness = 250
        textSidebar.allowsFullHeightLayout = true
        textSidebar.isSpringLoaded = true
        return textSidebar
    }()

    private lazy var canvasItem = NSSplitViewItem(viewController: canvas)

    private lazy var settingsSidebar: NSSplitViewItem = {
        let settingsSplit = NSSplitViewItem(inspectorWithViewController: settings)
        settingsSplit.minimumThickness = 400
        settingsSplit.maximumThickness = 400
        return settingsSplit
    }()

    var document: VODesignDocument!
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        addSplitViewItem(textSidebar)
        addSplitViewItem(canvasItem)
        addSplitViewItem(settingsSidebar)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        canvas.presenter
            .selectedPublisher
            .sink(receiveValue: updateSelection(_:))
            .store(in: &cancellables)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
        
        canvas.presenter.stopObserving()
    }

    override func cancelOperation(_ sender: Any?) {
        canvas.presenter.cancelOperation()
    }
}

// MARK: Settings visibility
extension ProjectController {
    private func updateSelection(_ selectedModel: (any ArtboardElement)?) {
        if let selectedModel = selectedModel {
            showSettings(for: selectedModel)
        } else {
            hideSettings()
        }
    }

    func showSettings(for model: any ArtboardElement) {
        switch model.cast {
        case .frame(let frame):
            settings.state = .frame(frame)
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
    
    public func delete(model: any ArtboardElement) {
        canvas.delete(model: model)
        settings.state = .empty
    }
}

extension CanvasViewController: RecognitionImageSource {}
