import AppKit
import Document
import CommonUI

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
        
        presenter.load()
    }
    
    /// Sometimel layout is called right after loading from storyboard, presenter is not set and a crash happened.
    /// I added check that presenter is not nil, but we had to call reloadData as as result
    private var needReloadDataOnStart = false

    func view() -> DocumentsBrowserView {
        view as! DocumentsBrowserView
    }
    
    private func createNewProject() {
        let document = VODesignDocument()
        show(document: document)
    }

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
    public func didDrag(path: URL) {
        let document = VODesignDocument(fileName: path.lastPathComponent,
                                        rootPath: path.deletingLastPathComponent())
        show(document: document)
    }
    
    public func didDrag(image: NSImage) {
        let document = VODesignDocument(image: image)
        show(document: document)
    }
}


extension DocumentsBrowserViewController : NSCollectionViewDataSource {
    
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        1
    }
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard presenter != nil else {
            needReloadDataOnStart = true
            return 0
        }
        return presenter.numberOfItemsInSection(section)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        switch presenter.item(at: indexPath)! {
        case .newDocument:
            let item = collectionView.makeItem(withIdentifier: NewDocumentCollectionViewItem.identifier, for: indexPath)
            return item
        case .document(let url):
            let item = collectionView.makeItem(withIdentifier: DocumentCellViewItem.identifier, for: indexPath) as! DocumentCellViewItem
            item.configure(
                fileName: url.fileName
            )

            Task {
                // TODO: Move inside Document's model
                // TODO: Cache in not working yet
                let frameURL = url.frameURL(frameName: defaultFrameName)
                let image = await ThumbnailDocument(frameURL: frameURL)
                    .thumbnail(size: item.expectedImageSize,
                               scale: backingScaleFactor)
                
                item.image = image
                // TODO: Check that cell hasn't been reused
            }
            
            return item
        case .sample(let downloadableDocument):
            let item = collectionView.makeItem(withIdentifier: NewDocumentCollectionViewItem.identifier, for: indexPath)
            return item
        }
    }
}

extension DocumentsBrowserViewController: NSCollectionViewDelegate {
    
    public func collectionView(
        _ collectionView: NSCollectionView,
        didSelectItemsAt indexPaths: Set<IndexPath>
    ) {
        for indexPath in indexPaths {
            switch presenter.item(at: indexPath)! {
            case .document(let url):
                let document = VODesignDocument(file: url)
                show(document: document)
                
            case .newDocument:
                createNewProject()
            case .sample(let downloadableDocument):
                break // TODO: Load and open
            }
        }
    }
}

extension DocumentsBrowserViewController {
    func toolbar() -> NSToolbar {
        let toolbar = NSToolbar()
        return toolbar
    }
}


extension DocumentsBrowserViewController: DocumentsProviderDelegate {
    public func didUpdateDocuments() {
        view().collectionView.reloadData()
    }
}

