import Foundation
import Samples

/// Type of cell in collection view
public enum CollectionViewItem {
    /// Regular (existing) document item
    case document(URL)
    /// Add new document item
    case newDocument
    /// Downloadable sample
    case sample(DownloadableDocument)
}

public protocol DocumentBrowserPresenterProtocol {
    var delegate: DocumentsProviderDelegate? { get set }
    
    func numberOfItemsInSection(_ section: Int) -> Int
    func item(at indexPath: IndexPath) -> CollectionViewItem?
    
    var shouldShowThisController: Bool { get }
    func load()
}

public class DocumentPresenterFactory {
    public init() {}
    
    public func presenter() -> DocumentBrowserPresenterProtocol {
//        UserDocumentsPresenter()
        SamplesDocumentsPresenter()
    }
}

public struct DownloadableDocument {
    let path: DocumentPath
    let isCached: Bool
}
