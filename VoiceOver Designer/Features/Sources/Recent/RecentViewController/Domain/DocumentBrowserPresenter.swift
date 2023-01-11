import Foundation
import Document
import AppKit

/// Type of cell in collection view
enum CollectionViewItem {
    /// Regular (existing) document item
    case document(URL)
    /// Add new document item
    case newDocument
}

public class DocumentBrowserPresenter {
    let fileManager = FileManager.default
    public weak var documentController: NSDocumentController? = VODocumentController.shared
    
    public init() {}
    
    public var shouldShowThisController: Bool {
        let hasRecentDocuments = !recentItems.isEmpty
        let hasCloudDocuments = !iCloudDocuments.isEmpty
        
        return hasRecentDocuments || hasCloudDocuments
    }
    
    private var recentItems: [URL] {
        documentController?.recentDocumentURLs ?? []
    }
    
    private let metadataProvider = MetadataProvider(containerIdentifier: containerId,
                                                    fileExtension: vodesign)
    
    weak var delegate: DocumentsProviderDelegate? {
        didSet {
            metadataProvider?.delegate = delegate
        }
    }
    private var iCloudDocuments: [URL] {
        let metaFiles = metadataProvider?
            .metadataItemList()
            .map { meta in
                meta.url
            }
        
        return metaFiles ?? []
    }
    
    private var items: [CollectionViewItem] {
        let arrayOfURLs = iCloudDocuments.union(with: recentItems)
        
        // TODO: Sort by recent modified date
        
        let documents = arrayOfURLs
            .map { url in
            CollectionViewItem.document(url)
        }
        
        return [.newDocument] + documents
    }
    
    // MARK: - Datasource
    func numberOfItemsInSection(_ section: Int) -> Int {
        return items.count
    }
    
    func item(at indexPath: IndexPath) -> CollectionViewItem? {
        items[indexPath.item]
    }
}
