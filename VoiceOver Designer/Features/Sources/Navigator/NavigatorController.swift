import AppKit
import Combine
import Document
import Artboard

public class NavigatorController: NSViewController {
    
    var presenter: DocumentPresenter!
    
    @IBOutlet var outlineView: NSOutlineView!
    
    func inject(document: VODesignDocument,
                presenter: DocumentPresenter)
    {
        self.document = document
        self.presenter = presenter
    }
    
    var document: VODesignDocument!
    var draggedNode: (any ArtboardElement)?
    
    private var cancellables = Set<AnyCancellable>()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        enableDragging()
        
        outlineView.style = .sourceList
        outlineView.allowsMultipleSelection = true
    }
    
    public override func viewDidAppear() {
        super.viewDidAppear()
        
        observe()
    }
    
    public override func viewWillDisappear() {
        super.viewWillDisappear()
        
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
    private func observe() {
        presenter.artboardPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            
            outlineView.reloadData()
            select(model: presenter.selectedPublisher.value)
            updateToolbarButton()
            
        }.store(in: &cancellables)
        
        presenter.selectedPublisher
            .scan(nil, deselect(current:next:))
            .sink(receiveValue: select(model:))
            .store(in: &cancellables)
    }
    
    /**
     Deselects current element and passes next upstream
        - parameters:
            - current: A currently selected ``ArtboardElement`` in the upstream
            - next: A new value to select in the upstream
        - returns: A next value to select
     */
    private func deselect(current: (any ArtboardElement)?, next: (any ArtboardElement)?) -> (any ArtboardElement)? {
        updateCell(for: current, shouldSelect: false)
        return next
    }
    
    private func select(model: (any ArtboardElement)?) {
        guard let model = model else {
            outlineView.deselectAll(self)
            return
        }
        
        let index = outlineView.row(forItem: model)
        
        updateCell(for: model, shouldSelect: true)
        
        
        guard isValid(row: index) else {
            return expandAndSelect(model)
        }
        
        outlineView.selectRowIndexes(IndexSet(integer: index),
                                     byExtendingSelection: false)
    }
    
    private func expandAndSelect(_ element: any ArtboardElement) {
        expandParents(of: element)
        
        let rowToSelect = outlineView.row(forItem: element)
        guard isValid(row: rowToSelect) else { return }
        
        outlineView.selectRowIndexes(IndexSet(integer: rowToSelect), byExtendingSelection: false)
    }
    
    private func expandParents(of element: any ArtboardElement) {
        // Iterate parents
        var elementToExpand: Child = element
        var elementsToExpand = [Any]()
        while let parent = elementToExpand.parent {
            elementsToExpand.append(parent)
            elementToExpand = parent
        }
        
        // Expand starting from top elements
        for elementToExpand in elementsToExpand.reversed() {
            outlineView.expandItem(elementToExpand, expandChildren: false)
        }
    }

    /**
        Checks if is row valid based on value ``NSOutlineView/row(forItem:)``
        - parameters:
            - row: An integer value
        - returns: A Boolean that indicates is row valid or not
     */
    private func isValid(row: Int) -> Bool {
        row != NSOutlineViewDropOnItemIndex
    }
    
    private func updateCell(for model: (any ArtboardElement)?, shouldSelect: Bool) {
        guard let model else { return }
        
        let row = outlineView.row(forItem: model)
        
        guard isValid(row:row), // TODO: Expand item at this case? Or select this item after expand
            let rowView = outlineView.rowView(atRow: row, makeIfNecessary: false),
            let cell = rowView.view(atColumn: 0) as? ElementCell
        else { return }
        
        shouldSelect ? cell.select() : cell.deselect()
    }
    
    @IBOutlet var groupButton: NSButton!
    
    @objc func groupSelection() {
        let selectedItems = outlineView.selectedRowIndexes
            .map { row in
                outlineView.item(atRow: row)
            } as! [any ArtboardElement]
        
        let container = presenter.wrapInContainer(selectedItems)

        select(model: container)
    }
    
    @objc func ungroup() {
        guard outlineView.selectedRowIndexes.count == 1 else { return }
        guard let container = outlineView.item(atRow: outlineView.selectedRow) as? A11yContainer else { return }
        presenter.unwrapContainer(container)
        select(model: container.elements.last)
    }
}

extension NavigatorController: NSOutlineViewDataSource {
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        switch item {
        case .none:
            // Top-level frames
            return document.artboard.elements.count
        case let frame as Frame:
            // Containers
            return frame.elements.count
        case let container as A11yContainer:
            // Elements
            return container.elements.count
        default:
            // Default
            return 0
        }
    }
    
    public func outlineView(_ outlineView: NSOutlineView,
                            child index: Int,
                            ofItem item: Any?
    ) -> Any {
        switch item {
        case .none:
            return document.artboard.elements[index]
        case let frame as Frame:
            return frame.elements[index]
        case let container as A11yContainer:
            return container.elements[index]
        default:
            fatalError()
        }
    }
    
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        switch item {
        case is Frame:
            return true
        case is A11yContainer:
            return true
        default:
            return false
        }
    }
}

extension NavigatorController: NSOutlineViewDelegate {
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let id = NSUserInterfaceItemIdentifier("Element")
        
        let view = outlineView.makeView(withIdentifier: id, owner: self) as! ElementCell
        
        let model = item as? any ArtboardElement
        view.setup(model: model)
        
        return view
    }
    
    
    public func outlineViewSelectionDidChange(_ notification: Notification) {
        defer { updateToolbarButton() }
        guard let outlineView = notification.object as? NSOutlineView else { return }
        
        guard outlineView.selectedRowIndexes.count == 1 else {
            return // Not forward multiple selection to whole app
        }
        
        let selectedItem = outlineView.item(atRow: outlineView.selectedRow)
        if let element = selectedItem as? any ArtboardElement  {
            presenter.selectedPublisher.send(element)
        }
    }
    
    func updateToolbarButton() {
        let selectedCount = outlineView.selectedRowIndexes.count

        groupButton.isEnabled = selectedCount != 0
        
        if selectedCount == 1, outlineView.item(atRow: outlineView.selectedRow) is A11yContainer {
            groupButton.action = #selector(ungroup)
            groupButton.title = NSLocalizedString("Ungroup Container", comment: "")
        } else {
            groupButton.action = #selector(groupSelection)
            groupButton.title = NSLocalizedString("Group in Container", comment: "")
        }
    }
}

extension NavigatorController {
    public static func fromStoryboard(
        document: VODesignDocument,
        presenter: DocumentPresenter
    ) -> NavigatorController {
        let controller = NSStoryboard(
            name: "NavigatorController",
            bundle: Bundle.module
        ).instantiateInitialController() as! NavigatorController
        
        controller.inject(
            document: document,
            presenter: presenter
        )
        
        return controller
    }
}
