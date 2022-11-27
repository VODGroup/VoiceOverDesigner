import AppKit
import Combine
import Document

public protocol TextBasedPresenter {
    var selectedPublisher: OptionalDescriptionSubject { get }
}

public class TextRepresentationController: NSViewController {
    
    var presenter: TextBasedPresenter!
    
    @IBOutlet var outlineView: NSOutlineView!
    
    func inject(document: VODesignDocument,
                presenter: TextBasedPresenter)
    {
        self.document = document
        self.presenter = presenter
    }
    
    var document: VODesignDocument!
    var draggedNode: A11yDescription?
    
    private var cancellables = Set<AnyCancellable>()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        enableDragging()
        
        observe()
        
        outlineView.style = .sourceList
    }
    
    private func observe() {
        document.controlsPublisher.sink { [weak self] _ in
            self?.outlineView.reloadData()
        }.store(in: &cancellables)
        
        presenter.selectedPublisher
            .sink(receiveValue: select(model:))
            .store(in: &cancellables)
    }
    
    private func select(model: A11yDescription?) {
        guard let model = model else {
            outlineView.deselectAll(self)
            return
        }
        
        guard let index = document.controls.firstIndex(where: { aModel in
            aModel === model
        }) else { return }
        
        updateAttributedLabel(for: model, isSelected: true)
        
        outlineView.selectRowIndexes(IndexSet(integer: index),
                                     byExtendingSelection: false)
    }
    
    private func updateAttributedLabel(for model: (any AccessibilityView)?, isSelected: Bool) {
        guard let model else { return }
        
        let index = document.controls.firstIndex(where: { aView in
            aView === model
        })
        guard let index else { return }
        
        guard let rowView = outlineView.rowView(atRow: index, makeIfNecessary: false) else { return }
        guard let cell = rowView.view(atColumn: 0) as? ElementCell else { return }
        
        cell.setup(model: model, isSelected: isSelected)
    }
}

extension TextRepresentationController: NSOutlineViewDataSource {
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let container = item as? A11yContainer {
            return container.elements.count
        }
        
        return document.controls.count
    }
    
    public func outlineView(_ outlineView: NSOutlineView,
                            child index: Int,
                            ofItem item: Any?
    ) -> Any {
        if let container = item as? A11yContainer {
            return container.elements[index]
        }
        
        return document.controls[index]
    }
    
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is A11yContainer {
            return true
        }
        
        return false
    }
}

extension TextRepresentationController: NSOutlineViewDelegate {
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let id = NSUserInterfaceItemIdentifier("Element")
        
        let view = outlineView.makeView(withIdentifier: id, owner: self) as! ElementCell
        
        let model = item as? any AccessibilityView
        view.setup(model: model,
                   isSelected: false)
        
        return view
    }
    
    public func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else { return }
        
        // Deselection of previous value
        let previousSelection = presenter.selectedPublisher.value
        updateAttributedLabel(for: previousSelection, isSelected: false)
        
        if let model = outlineView.item(atRow: outlineView.selectedRow) as? A11yDescription {
            updateAttributedLabel(for: model, isSelected: true)
            presenter.selectedPublisher.send(model)
        }
    }
}

extension TextRepresentationController {
    public static func fromStoryboard(
        document: VODesignDocument,
        presenter: TextBasedPresenter
    ) -> TextRepresentationController {
        let controller = NSStoryboard(
            name: "TextRepresentationController",
            bundle: Bundle.module
        ).instantiateInitialController() as! TextRepresentationController
        
        controller.inject(
            document: document,
            presenter: presenter
        )
        
        return controller
    }
}
