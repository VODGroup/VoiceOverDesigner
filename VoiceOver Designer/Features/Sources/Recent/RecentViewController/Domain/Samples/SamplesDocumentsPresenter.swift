import Foundation
import Samples

class SamplesDocumentsPresenter: DocumentBrowserPresenterProtocol {
    weak var delegate: DocumentsProviderDelegate?
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        items.count
    }
    
    func item(at indexPath: IndexPath) -> CollectionViewItem? {
        items[indexPath.item]
    }
    
    var shouldShowThisController: Bool = true
    
    private var items = [CollectionViewItem]()
    
    var possibleLanguages = [String]()
    var structure: SamplesStructure?
    
    func load() {
        Task {
            do {
                let structure = try await SamplesLoader().loadStructure()
                self.structure = structure
                self.possibleLanguages = structure.languages.map { pair in String(pair.key) }
                
                let ru = structure.languages.keys.first! // TODO: Choose language
                
                await MainActor.run(body: {
                    presentProjects(with: ru)
                })
                
            } catch let error {
                // TODO: Add retry button
                print(error)
            }
        }
    }
}

extension SamplesDocumentsPresenter: LanguageSource {
    func presentProjects(with language: String) {
        let projects = structure!.languages[language]!
        
        self.items = projects.map({ project in
            CollectionViewItem.sample(DownloadableDocument(path: project, isCached: false))
        })
        
        delegate?.didUpdateDocuments()
    }
}
