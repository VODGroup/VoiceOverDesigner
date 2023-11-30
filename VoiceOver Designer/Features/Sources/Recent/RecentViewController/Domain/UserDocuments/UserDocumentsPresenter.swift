import Foundation
import Document
import AppKit

class UserDocumentsPresenter: DocumentBrowserPresenterProtocol {
    let fileManager = FileManager.default
    
    private var documentController: NSDocumentController {
        NSDocumentController.shared
    }
    
    public init() {}
    
    var shouldShowThisController: Bool {
        let hasRecentDocuments = !recentItems.isEmpty
        let hasCloudDocuments = !iCloudDocuments.isEmpty
        
        return hasRecentDocuments || hasCloudDocuments
    }
    
    private var recentItems: [URL] {
        documentController.recentDocumentURLs
    }
    
    private let metadataProvider = MetadataProvider(containerIdentifier: containerId,
                                                    fileExtension: vodesign)
    
    public weak var delegate: DocumentsProviderDelegate? {
        didSet {
            metadataProvider?.delegate = delegate
        }
    }
    private var iCloudDocuments: [URL] {
        let metaFiles = metadataProvider?
            .metadataItemList()
            .map(\.url)
        
        return metaFiles ?? []
    }
    
    private var items: [DocumentBrowserCollectionItem] {
        let arrayOfURLs = iCloudDocuments.union(with: recentItems)
        
        // TODO: Sort by recent modified date
        
        let documents = arrayOfURLs
            .map { url in
                DocumentBrowserCollectionItem(
                    content: .document(url),
                    menu: makeDocumentMenu(for: url),
                    renameAction: makeRenameAction(for: url))
            }
        
        return [DocumentBrowserCollectionItem(content: .newDocument)] + documents
    }
    
    
    private func makeDocumentMenu(for url: URL) -> [DocumentBrowserCollectionItem.MenuAction] {
        var items: [DocumentBrowserCollectionItem.MenuAction] = [
            .init(name: NSLocalizedString("Delete", comment: ""), keyEquivalent: "") { [weak self] in
                guard let self else { return }
                self.deleteDocument(at: url)
            },
            .init(name: NSLocalizedString("Duplicate", comment: ""), keyEquivalent: "") { [weak self] in
                guard let self else { return }
                self.duplicate(url)
            }]
        if FileManager.default.iCloudAvailable {
            items.append(.init(name: NSLocalizedString("Move to iCloud", comment: ""), keyEquivalent: "") { [weak self] in
                guard let self else { return }
                self.moveToCloud(url)
            })
        }
        
        return items
    }
    
    private func makeRenameAction(for url: URL) -> DocumentRenameAction {
        DocumentRenameAction(
            name: NSLocalizedString("Rename", comment: ""),
            keyEquivalent: ""
        ) { [weak self] value in
            guard let self else { return }
            try self.rename(url, with: value)
        }
    }
    
    
    func deleteDocument(at url: URL) {
        do {
            try fileManager.removeItem(at: url)
        } catch {
            // Handling
            Swift.print(error)
        }
    }
    
    func duplicate(_ documentURL: URL) {
        do {
            try documentController.duplicateDocument(withContentsOf: documentURL, copying: true, displayName: documentURL.fileName)
        } catch {
            Swift.print(error)
        }
    }
    
    // TODO: Find a way to access document url otherwise cannot move file
    func moveToCloud(_ documentURL: URL) {
        guard let iCloudDirectory = fileManager.iCloudDirectory else { return }
        let document = VODesignDocument(file: documentURL)
        Task { @MainActor in
            do {
                try await document.move(to: iCloudDirectory)
            }
            catch {
                print("Failed to rename document at \(documentURL) to \(iCloudDirectory) with error: \(error)")
            }
            delegate?.didUpdateDocuments()
        }
    }
    
    #warning("TODO: Find a way to access document url otherwise cannot rename")
    func rename(_ documentURL: URL, with name: String) throws {
        
        let document = VODesignDocument(file: documentURL)
        let destinationURL = documentURL.deletingLastPathComponent().appendingPathComponent(name).appendingPathExtension(vodesign)
        Task { @MainActor in
            do {
                try await document.move(to: destinationURL)
            }
            catch {
                print("Failed to rename document at \(documentURL) to \(destinationURL) with error: \(error)")
            }
            delegate?.didUpdateDocuments()
        }
        
        
        
    }
    
    
    
    // MARK: - Datasource
    func load() {
        metadataProvider?.load()
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return items.count
    }
    
    func item(at indexPath: IndexPath) -> DocumentBrowserCollectionItem {
        items[indexPath.item]
    }
    
    func title(for section: Int) -> String? {
        nil
    }
}
