import Foundation
import Samples
import Document


public protocol DocumentBrowserPresenterProtocol {
    var delegate: DocumentsProviderDelegate? { get set }
    
    func numberOfSections() -> Int
    func title(for section: Int) -> String?
    
    func numberOfItemsInSection(_ section: Int) -> Int
    func item(at indexPath: IndexPath) -> DocumentBrowserCollectionItem
    
    var shouldShowThisController: Bool { get }
    func load()
    
}

public protocol LanguageSource {
    var samplesLanguage: String? { get }
    var possibleLanguages: [String] { get }
    
    func presentProjects(with language: String)
}

extension DocumentBrowserPresenterProtocol {
    
    func document(at indexPath: IndexPath) async throws -> VODesignDocument {
        switch item(at: indexPath).content {
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
