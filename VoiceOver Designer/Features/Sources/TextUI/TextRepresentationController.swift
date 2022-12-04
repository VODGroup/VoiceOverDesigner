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
    var draggedNode: (any AccessibilityView)?
    
    private var cancellables = Set<AnyCancellable>()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        enableDragging()
        
        observe()
        
        outlineView.style = .sourceList
        outlineView.allowsMultipleSelection = true
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
        
        let index = outlineView.row(forItem: model)
        
        updateAttributedLabel(for: model, isSelected: true)
        
        outlineView.selectRowIndexes(IndexSet(integer: index),
                                     byExtendingSelection: false)
    }
    
    private func updateAttributedLabel(for model: (any AccessibilityView)?, isSelected: Bool) {
        guard let model else { return }
        
        let index = outlineView.row(forItem: model)
        
        guard let rowView = outlineView.rowView(atRow: index, makeIfNecessary: false) else { return }
        guard let cell = rowView.view(atColumn: 0) as? ElementCell else { return }
        
        cell.setup(model: model, isSelected: isSelected)
    }
    
    @IBOutlet var groupButton: NSButton!
    
    @IBAction func groupSelection(_ sender: AnyObject) {
        let selectedItems = outlineView.selectedRowIndexes
            .map { row in
                outlineView.item(atRow: row)
            } as! [any AccessibilityView]
        
        document.controls.wrapInContainer(
            selectedItems.extractElements(),
            label: "Container")
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
        
        guard outlineView.selectedRowIndexes.count == 1 else {
            groupButton.isEnabled = true
            return // Not farward multiple seleciton to whole app
        }
        groupButton.isEnabled = false
        

        
        let selectedItem = outlineView.item(atRow: outlineView.selectedRow)
        if let element = selectedItem as? A11yDescription {
            updateAttributedLabel(for: element, isSelected: true)
            presenter.selectedPublisher.send(element)
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
