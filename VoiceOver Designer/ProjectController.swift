import Editor
import TextUI
import Settings
import AppKit
import Document
import Combine

extension EditorPresenter: TextBasedPresenter {}

class ProjectController: NSSplitViewController {
    
    lazy var router = Router(rootController: self, settingsDelegate: self)
    
    var editor: EditorViewController!
    var textContent: TextRepresentationController!
    var document: VODesignDocument!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editorPresenter = EditorPresenter(document: document)
        
        editor = EditorViewController.fromStoryboard()
        
        textContent = TextRepresentationController.fromStoryboard(
            document: document,
            presenter: editorPresenter)
        
        editor.inject(presenter: editorPresenter)
        
        addSplitViewItem(NSSplitViewItem(sidebarWithViewController: textContent))
        addSplitViewItem(NSSplitViewItem(viewController: editor))
        
        editor.presenter
            .selectedPublisher
            .sink(receiveValue: updateSelection(_:))
            .store(in: &cancellables)
    }
    
    private func updateSelection(_ selectedModel: A11yDescription?) {
        if let selectedModel = selectedModel {
            router.showSettings(for: selectedModel)
        } else {
            router.hideSettings()
        }
    }
    
    public func inject(
        document: VODesignDocument
    ) {
        self.document = document
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
