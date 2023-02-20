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
        projectPath.cachePath()
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
    
    public func invalidate() async throws {
        try await forceDownload(files: document.files, documentURL: projectPath.documentBaseURL(), saveTo: documentPathInCache)
    }
    
    public func clearCache() throws {
        try dataCache.removeFile(at: documentPathInCache)
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
    
    
    private func forceDownload(
        files: [String],
        documentURL: URL,
        saveTo resultDocumentPath: URL
    ) async throws {
        
        await withThrowingTaskGroup(of: Void.self) { group in
            for file in files {
                group.addTask { [dataCache] in
                    try await dataCache.download(
                        downloadUrl: documentURL.appendingPathComponent(file),
                        cacheUrl: resultDocumentPath.appendingPathComponent(file))
                }
            }
        }
    }
    
    private func download(
        files: [String],
        documentURL: URL,
        saveTo resultDocumentPath: URL
    ) async throws {
        
        await withThrowingTaskGroup(of: Void.self) { group in
            for file in files {
                group.addTask { [dataCache] in
                    try await dataCache.downloadIfCacheIsEmpty(
                        downloadUrl: documentURL.appendingPathComponent(file),
                        cacheUrl: resultDocumentPath.appendingPathComponent(file))
                }
            }
        }
    }
    
    let dataCache = DataCache()
    
    private let fileManager = FileManager.default
}
