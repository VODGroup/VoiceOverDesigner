import Foundation
import Document
import AppKit

class UserDocumentsPresenter: DocumentBrowserPresenterProtocol {
    let fileManager = FileManager.default
    public weak var documentController: NSDocumentController? = VODocumentController.shared
    
    public init() {}
    
    var shouldShowThisController: Bool {
        let hasRecentDocuments = !recentItems.isEmpty
        let hasCloudDocuments = !iCloudDocuments.isEmpty
        
        return hasRecentDocuments || hasCloudDocuments
    }
    
    private var recentItems: [URL] {
        documentController?.recentDocumentURLs ?? []
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
            .init(name: "Delete", keyEquivalent: "") { [weak self] in
                guard let self else { return }
                self.deleteDocument(at: url)
            },
            .init(name: "Duplicate", keyEquivalent: "") { [weak self] in
                guard let self else { return }
                self.duplicate(url)
            }]
        if FileManager.default.iCloudAvailable {
            items.append(.init(name: "Move to iCloud", keyEquivalent: "") { [weak self] in
                guard let self else { return }
                self.moveToCloud(url)
            })
        }
        
        return items
    }
    
    private func makeRenameAction(for url: URL) -> DocumentRenameAction {
        DocumentRenameAction(
            name: "Rename",
            keyEquivalent: ""
        ) { [weak self] value in
            guard let self else { return }
            try self.rename(url, with: value)
        }
    }
    
    
    //
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
            try documentController?.duplicateDocument(withContentsOf: documentURL, copying: true, displayName: documentURL.fileName)
        } catch {
            Swift.print(error)
        }
    }
    
    
    func moveToCloud(_ documentURL: URL) {
        guard let iCloudDirectory = fileManager.iCloudDirectory else { return }
        do {
            // Move to cloud directory
            try fileManager.moveItem(at: documentURL, to: iCloudDirectory)
        } catch {
            // Handling
            Swift.print(error)
        }
    }
    
    func rename(_ documentURL: URL, with name: String) throws {
        
        try fileManager.moveItem(at: documentURL, to: documentURL.deletingLastPathComponent().appendingPathComponent(name).appendingPathExtension(vodesign))
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
