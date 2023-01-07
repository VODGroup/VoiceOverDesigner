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

public class RecentPresenter {
    let fileManager = FileManager.default
    public weak var documentController: NSDocumentController? = VODocumentController.shared
    
    public init() {}
    
    public var shouldShowThisController: Bool {
        let hasRecentDocuments = !VODocumentController.shared.recentDocumentURLs.isEmpty
        let hasCloudDocuments = try! !fileManager.contentsOfDirectory(at: iCloudContainer, includingPropertiesForKeys: nil).isEmpty
        
        return hasRecentDocuments || hasCloudDocuments
    
    }
    
    private var hasRecentDocuments: Bool {
        !VODocumentController.shared.recentDocumentURLs.isEmpty
    }
    
    var recentItems: [URL] {
        documentController?.recentDocumentURLs ?? []
    }
    
    private let metadataProvider = MetadataProvider(containerIdentifier: containerId,
                                                    fileExtension: vodesign)
    var iCloudDocuments: [URL] {
        let metaFiles = metadataProvider?
            .metadataItemList()
            .map { meta in
                meta.url
            }
        
        return metaFiles ?? []
    }
    
    var items: [CollectionViewItem] {
        let set = NSOrderedSet(array: /*recentItems +*/ iCloudDocuments) // TODO: Add recent local files and write test for union
        let arrayOfURLs = set
            .array as! [URL]
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
