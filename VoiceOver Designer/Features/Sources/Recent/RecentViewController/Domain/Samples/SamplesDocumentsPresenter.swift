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
    
    
    private let samplesLoader = SampleLoader()
    
    private var items = [CollectionViewItem]()
    
    func load() {
        Task {
            do {
                let structure = try await samplesLoader.loadStructure()
                
                let ru = structure.languages.keys.first! // TODO: Choose language
                
                let projects = structure.languages[ru]!
                
                self.items = projects.map({ project in
                    CollectionViewItem.sample(DownloadableDocument(path: project, isCached: false))
                })
                
                await MainActor.run {
                    delegate?.didUpdateDocuments()
                }
                
            } catch let error {
                // TODO: Add retry button
                print(error)
            }
        }
    }
}

