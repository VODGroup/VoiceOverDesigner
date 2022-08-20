import Editor
import TextUI
import Settings
import AppKit
import Document
import Combine

extension EditorPresenter: TextBasedPresenter {}

class ProjectController: NSSplitViewController {
    
    init(document: VODesignDocument) {
        let editorPresenter = EditorPresenter(document: document)
        
        textContent = TextRepresentationController.fromStoryboard(
            document: document,
            presenter: editorPresenter)
        
        editor = EditorViewController.fromStoryboard()
        editor.inject(presenter: editorPresenter)
        
        settings = SettingsStateViewController.fromStoryboard()
        
        super.init(nibName: nil, bundle: nil)
        
        settings.settingsDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let textContent: TextRepresentationController
    let editor: EditorViewController
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
        settingsSidebar.allowsFullHeightLayout = true
        
        addSplitViewItem(textSidebar)
        addSplitViewItem(NSSplitViewItem(viewController: editor))
        addSplitViewItem(settingsSidebar)
        
        editor.presenter
            .selectedPublisher
            .sink(receiveValue: updateSelection(_:))
            .store(in: &cancellables)
    }
}

// MARK: Settings visibility
extension ProjectController {
    private func updateSelection(_ selectedModel: A11yDescription?) {
        if let selectedModel = selectedModel {
            showSettings(for: selectedModel)
        } else {
            hideSettings()
        }
    }
    
    func showSettings(for model: A11yDescription) {
        settings.state = .control(model)
    }
    
    func hideSettings() {
        settings.state = .empty
    }
}

extension ProjectController: SettingsDelegate {
    public func didUpdateValue() {
        editor.save()
    }
    
    public func delete(model: A11yDescription) {
        editor.delete(model: model)
    }
}
