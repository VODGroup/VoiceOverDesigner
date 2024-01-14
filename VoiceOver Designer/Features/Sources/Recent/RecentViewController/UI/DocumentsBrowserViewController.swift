import AppKit
import Document
import CommonUIAppKit
import Samples

public protocol RecentRouter: AnyObject {
    func show(document: VODesignDocument) -> Void
}

public class DocumentsBrowserViewController: NSViewController {

    public weak var router: RecentRouter?
    var presenter: DocumentBrowserPresenterProtocol! {
        didSet {
            if needReloadDataOnStart {
                view().collectionView.reloadData()
            }
            
            presenter.delegate = self
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view().collectionView.dataSource = self
        view().collectionView.delegate = self
        
        view().collectionView.register(
            HeaderCell.self,
            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
            withIdentifier: HeaderCell.id
        )
        presenter.load()
       
        
    }
    
    /// Sometimel layout is called right after loading from storyboard, presenter is not set and a crash happened.
    /// I added check that presenter is not nil, but we had to call reloadData as as result
    private var needReloadDataOnStart = false
    
    private var editingIndexPath: IndexPath?

    func view() -> DocumentsBrowserView {
        view as! DocumentsBrowserView
    }

    @MainActor
    private func show(document: VODesignDocument) {
        router?.show(document: document)
    }
    
    public static func fromStoryboard() -> DocumentsBrowserViewController {
        let storyboard = NSStoryboard(name: "DocumentsBrowserViewController", bundle: .module)
        return storyboard.instantiateInitialController() as! DocumentsBrowserViewController
    }
    
    lazy var backingScaleFactor: CGFloat = {
        view.window?.backingScaleFactor ??  NSScreen.main?.backingScaleFactor ?? 1
    }()
}

extension DocumentsBrowserViewController: DragNDropDelegate {
    public func didDrag(path: URL) -> Bool {
        let document = VODesignDocument(fileName: path.lastPathComponent,
                                        rootPath: path.deletingLastPathComponent())
        show(document: document)
        return true
    }
    
    public func didDrag(image: NSImage, locationInWindow: CGPoint, name: String?) {
        let document = VODesignDocument(image: image)
        show(document: document)
    }
}

extension DocumentsBrowserViewController : NSCollectionViewDataSource {
    
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        presenter.numberOfSections()
    }
    
    public func collectionView(
        _ collectionView: NSCollectionView,
        viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
        at indexPath: IndexPath
    ) -> NSView {
        let view = collectionView.makeSupplementaryView(ofKind: kind,
                                                        withIdentifier: HeaderCell.id,
                                                        for: indexPath) as! HeaderCell
        view.label.stringValue = presenter.title(for: indexPath.section) ?? ""
        return view
    }
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard presenter != nil else {
            needReloadDataOnStart = true
            return 0
        }
        return presenter.numberOfItemsInSection(section)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let collectionItem = presenter.item(at: indexPath)
        
        switch collectionItem.content {
        case .newDocument:
            let item = collectionView.makeItem(
                withIdentifier: NewDocumentCollectionViewItem.identifier,
                for: indexPath)
            return item
        case .document(let url):
            let item = collectionView.makeItem(
                withIdentifier: DocumentCellViewItem.identifier,
                for: indexPath) as! DocumentCellViewItem
            item.configure(
                fileName: url.fileName
            )
            
            item.configureContextMenu(items: collectionItem.menu.map(\.item),
                                      renameAction: collectionItem.renameAction)

            item.readThumbnail(documentURL: url,
                               backingScaleFactor: backingScaleFactor)
            
            return item
        case .sample(let downloadableDocument):
            let item = collectionView.makeItem(
                withIdentifier: DocumentCellViewItem.identifier,
                for: indexPath) as! DocumentCellViewItem
            
            item.configure(
                fileName: downloadableDocument.path.name
            )
            
            item.configureContextMenu(items: collectionItem.menu.map(\.item),
                                      renameAction: collectionItem.renameAction)
            
            item.loadThumbnail(for: downloadableDocument.path,
                               backingScaleFactor: backingScaleFactor)
            
            return item
        }
    }
}

extension DocumentsBrowserViewController: NSCollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        if let _ = presenter.title(for: section) {
            return CGSize(width: 0, height: 50)
        } else {
            return .zero
        }
    }
    
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        // TODO: Connect with header insets
        NSEdgeInsets(top: 16, left: 16, bottom: 25, right: 16)
    }
}

extension DocumentsBrowserViewController: NSCollectionViewDelegate {
    public func collectionView(
        _ collectionView: NSCollectionView,
        didSelectItemsAt indexPaths: Set<IndexPath>
    ) {
        guard let indexPath = indexPaths.first else {
            return
        }
        
        let cell = collectionView.item(at: indexPath) as? DocumentCellViewItem
        cell?.projectCellView.state = .loading
        
        Task {
            do {
                let document = try await presenter.document(at: indexPath)
                
                await MainActor.run {
                    cell?.projectCellView.state = .image
                    show(document: document)
                    collectionView.deselectAll(self)
                }
            } catch let error {
                print(error)
            }
        }
    }
}

extension DocumentsBrowserViewController: DocumentsProviderDelegate {
    public func didUpdateDocuments() {
        view().collectionView.reloadData()
        
        view.window?.toolbar?.resetLanguageButton()
    }
}
