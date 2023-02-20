import Foundation
import Samples
import Document

class SamplesDocumentsPresenter: DocumentBrowserPresenterProtocol {

    
    weak var delegate: DocumentsProviderDelegate?
    
    private let loader = SamplesLoader()
    
    func numberOfSections() -> Int {
        sections.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        sections[section].documents.count
    }
    
    func item(at indexPath: IndexPath) -> DocumentBrowserCollectionItem {
        sections[indexPath.section]
            .documents[indexPath.item]
    }
    
    func title(for section: Int) -> String? {
        sections[section].title
    }
    
    var shouldShowThisController: Bool = true
    
    private var sections = [ProjectViewModel]()
    var possibleLanguages = [String]()
    var structure: SamplesStructure?
    
    func load() {
        Task {
            do {
                // Read cache fast
                if let structure = loader.prefetchedStructure() {
                    await handle(structure: structure)
                }
                
                // Update or load first time
                let structure = try await loader.loadStructure()
                await handle(structure: structure)
                
            } catch let error {
                // TODO: Add retry button
                print(error)
            }
        }
    }
    
    private func handle(structure: SamplesStructure) async {
        self.structure = structure
        self.possibleLanguages = structure.languages.map { pair in String(pair.key) }
        
        let language = language(from: possibleLanguages) // Remember last selected language
        
        await MainActor.run(body: {
            presentProjects(with: language)
        })
    }
    
    private func language(from possibleLanguages: [String]) -> String {
        if let currentCode = samplesLanguage,
           possibleLanguages.contains(currentCode)
        {
            return currentCode
        } else {
            return possibleLanguages.first!
        }
    }
    
    @Storage(key: "samplesLanguage", defaultValue: Locale.current.currentUserLanguage)
    var samplesLanguage: String?
    
    
    private func invalidate(sample: DocumentPath) {
        let sampleLoader = SampleLoader(document: sample)
        // MainActor needed to prevent update collection in background which causes crash
        Task { @MainActor in
            do {
                try await sampleLoader.invalidate()
                delegate?.didUpdateDocuments()
            } catch {
                print("Failed to invalidate sample document: \(sample.relativePath)")
            }
        }
    }
    
    
    private func removeCache(of sample: DocumentPath) {
        let sampleLoader = SampleLoader(document: sample)
        do {
            try sampleLoader.clearCache()
            delegate?.didUpdateDocuments()
        } catch {
            print("Failed to clear cache of sample document: \(sample.relativePath)")
        }
    }
}

extension Locale {
    var currentUserLanguage: String? {
        if #available(macOS 13, *) {
            return language.languageCode?.identifier
        } else {
            return languageCode
        }
    }
}

extension SamplesDocumentsPresenter: LanguageSource {
    func presentProjects(with language: String) {
        samplesLanguage = language
        let projects = structure!.languages[language]!
        
        self.sections = projects.map { project in
            ProjectViewModel(title: project.name,
                             documents: project.documents.map({ document in
                DocumentBrowserCollectionItem(content: .sample(
                    DownloadableDocument(path: document,
                                         isCached: false) // TODO: Move cache check to this property?
                ), menu: [
                    .init(name: NSLocalizedString("Invalidate", comment: ""), keyEquivalent: "") { [weak self] in
                        guard let self else { return }
                        self.invalidate(sample: document)
                    },
                    .init(name: NSLocalizedString("Clear cache", comment: ""), keyEquivalent: "") { [weak self] in
                        guard let self else { return }
                        self.removeCache(of: document)
                    }
                ])
            }))
        }
        
        
        delegate?.didUpdateDocuments()
    }
}

struct ProjectViewModel {
    let title: String
    let documents: [DocumentBrowserCollectionItem]
}
