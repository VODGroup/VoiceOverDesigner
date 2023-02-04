import Foundation
import Document

public class SampleLoader {

    private let document: DocumentPath
    private let projectPath: ProjectPath
    
    public init(document: DocumentPath) {
        self.document = document
        self.projectPath = ProjectPath(document: document)
    }
    
    public var documentPathInCache: URL {
        projectPath.cachaPath()
    }
    
    public func download() async throws -> URL {
        let projectURL = documentPathInCache
        
        if isFullyLoaded() {
            return projectURL
        } else {
            try await download(files: document.files,
                               documentURL: projectPath.documentBaseURL(),
                               saveTo: projectURL)
        }
        
        return projectURL
    }
    
    public func prefetch() async throws {
        try await download(files: [FolderName.quickLookPath],
                           documentURL: projectPath.documentBaseURL(),
                           saveTo: documentPathInCache)
    }
    
    public func isFullyLoaded() -> Bool {
        for file in document.files {
            let saveUrl = documentPathInCache.appendingPathComponent(file)
            let isExists = dataCache.hasFile(at: saveUrl)
            if !isExists {
                return false
            }
        }
        
        return true
    }
    
    private func download(
        files: [String],
        documentURL: URL,
        saveTo resultDocumentPath: URL
    ) async throws {
        for file in files {
            // TODO: Parallel
            try await dataCache.downloadIfCacheIsEmpty(
                downloadUrl: documentURL.appendingPathComponent(file),
                cacheUrl: resultDocumentPath.appendingPathComponent(file))
        }
    }
    
    let dataCache = DataCache()
    
    private let fileManager = FileManager.default
}
