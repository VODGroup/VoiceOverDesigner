import Foundation
import Samples
import Document

public class SamplesDocumentsPresenter: DocumentBrowserPresenterProtocol, LanguageSource {
    
    public private(set) static var shared = SamplesDocumentsPresenter()
    
    private init() {}
    
    weak public var delegate: DocumentsProviderDelegate?
    
    private let loader = SamplesLoader()
    
    public func numberOfSections() -> Int {
        sections.count
    }
    
    public func numberOfItemsInSection(_ section: Int) -> Int {
        sections[section].documents.count
    }
    
    public func item(at indexPath: IndexPath) -> DocumentBrowserCollectionItem {
        sections[indexPath.section]
            .documents[indexPath.item]
    }
    
    public func title(for section: Int) -> String? {
        sections[section].title
    }
    
    private var sections = [ProjectViewModel]()
    var structure: SamplesStructure?
    
    public func load() {
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
    
    // MARK: - LanguageSource
    
    @Storage(key: "samplesLanguage", defaultValue: Locale.current.currentUserLanguage)
    public var samplesLanguage: String?
    
    public var possibleLanguages = ["English", "Russian"]
    
    public func presentProjects(with language: String) {
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
    
    extension Locale {
        var currentUserLanguage: String? {
            if #available(macOS 13, *) {
                return language.languageCode?.identifier
            } else {
                return languageCode
            }
        }
    }

struct ProjectViewModel {
    let title: String
    let documents: [DocumentBrowserCollectionItem]
}
