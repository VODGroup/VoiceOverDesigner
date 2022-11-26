import AppKit
import Combine
import Document

public protocol TextBasedPresenter {
    var selectedPublisher: OptionalDescriptionSubject { get }
}

public class TextRepresentationController: NSViewController {
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
        guard let cell = rowView.view(atColumn: 0) as? NSTableCellView else { return }
        
        if isSelected {
            if let attributedString = cell.textField?.attributedStringValue {
                let stringToDeselect = NSMutableAttributedString(attributedString: attributedString)
                stringToDeselect.addAttribute(.foregroundColor, value: Color.white, range: NSRange(location: 0, length: stringToDeselect.length))
                cell.textField?.attributedStringValue = stringToDeselect
            }
        } else {
            if let element = model as? A11yDescription {
                cell.textField?.attributedStringValue = element.voiceOverTextAttributed(font: cell.textField?.font)
            } else if let container = model as? A11yContainer {
                cell.textField?.stringValue = container.label // TODO: Make bold?
            } else {
                cell.textField?.stringValue = NSLocalizedString("Unknown element", comment: "")
            }
        }
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
        switch item {
        case let control as A11yDescription:
            return a11yDescriptionCell(control, outlineView: outlineView)
        case let container as A11yContainer:
            return a11yContainerCell(container, outlineView: outlineView)
        default:
            return nil
        }
    }
    
    private func a11yDescriptionCell(_ descr: A11yDescription, outlineView: NSOutlineView) -> NSView? {
        let id = NSUserInterfaceItemIdentifier("Element")
        let view = outlineView.makeView(withIdentifier: id, owner: self) as! NSTableCellView
        
        view.textField?.attributedStringValue = descr.voiceOverTextAttributed(font: view.textField?.font)
        
        return view
    }
    
    private func a11yContainerCell(_ container: A11yContainer, outlineView: NSOutlineView) -> NSView? {
        let id = NSUserInterfaceItemIdentifier("Container")
        
        let view = outlineView.makeView(withIdentifier: id, owner: self) as! NSTableCellView
        
        view.textField?.stringValue = container.label
        
        return view
    }
    
    public func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else { return }
        
        // Deselection of previous value
        let previousSelection = presenter.selectedPublisher.value
        updateAttributedLabel(for: previousSelection, isSelected: false)
        
        if let model = outlineView.item(atRow: outlineView.selectedRow) as? A11yDescription {
            presenter.selectedPublisher.send(model)
        }
    }
}
