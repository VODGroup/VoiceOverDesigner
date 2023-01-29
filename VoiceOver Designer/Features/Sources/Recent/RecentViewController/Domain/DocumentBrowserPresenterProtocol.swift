import Foundation
import Samples
import Document

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

public protocol LanguageSource {
    var possibleLanguages: [String] { get }
    
    func presentProjects(with language: String)
}

extension DocumentBrowserPresenterProtocol {
    
    func document(at indexPath: IndexPath) async throws -> VODesignDocument {
        switch item(at: indexPath)! {
        case .document(let url):
            return await VODesignDocument(file: url)
            
        case .newDocument:
            return await VODesignDocument()
            
        case .sample(let downloadableDocument):
            let sampleLoader = SampleLoader(document: downloadableDocument.path)
            let url = try await sampleLoader
                .download()
            
            return await VODesignDocument(file: url)
        }
    }
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
