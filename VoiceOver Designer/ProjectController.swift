import Editor
import TextUI
import Settings
import AppKit
import Document

class ProjectController: NSSplitViewController {
    
    var editor: EditorViewController!
    var textContent: TextRepresentationController!
    lazy var router = Router(rootController: self, settingsDelegate: self)
    var document: VODesignDocument!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textContent = TextRepresentationController.fromStoryboard(
            document: document,
            actionDelegate: self)
        
        addSplitViewItem(NSSplitViewItem(sidebarWithViewController: textContent))
        addSplitViewItem(NSSplitViewItem(viewController: editor))
    }
}

extension ProjectController: TextRepresentationControllerDelegate {
    func didSelect(_ model: A11yDescription) {
        editor.select(model)
    }
}

extension ProjectController: EditorDelegate {
    func didSelect(control: A11yDescription?) {
        textContent.select(control)
    }
}

extension ProjectController: SettingsDelegate {
    public func didUpdateValue() {
        editor.save()
    }
    
    public func delete(control: A11yControl) {
        editor.delete(control: control)
    }
}
