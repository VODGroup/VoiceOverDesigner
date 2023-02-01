import Foundation
import Document

public class SamplesLoader {
    
    public init() {}
    
    public func loadStructure() async throws -> SamplesStructure {
        let (data, _) = try await URLSession.shared
            .data(from: ProjectPath.structurePath())
        
        let structure = try structure(from: data)
        
        try? dataCache.save(data: data, to: structurePath)
        
        return structure
    }
    
    private func structure(from data: Data) throws -> SamplesStructure {
        try JSONDecoder()
            .decode(SamplesStructure.self, from: data)
    }
    
    public func prefetchedStructure() -> SamplesStructure? {
        guard let data = try? Data(contentsOf: structurePath) else {
            return nil
        }
        
        let structure = try? structure(from: data)
        
        return structure
    }
    
    private var structurePath: URL {
        FileManager.default
            .samplesCacheFolder()
            .appendingPathComponent("structure.json")
    }
    
    let dataCache = DataCache()
}



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

class DataCache {
    func downloadIfCacheIsEmpty(
        downloadUrl: URL,
        cacheUrl: URL
    ) async throws {
        if fileManager.fileExists(atPath: cacheUrl.path) {
            print("File is exists, skip loading: \(cacheUrl) ")
            return
        }
        
        let (data, response) = try await URLSession.shared.data(from: downloadUrl)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        guard statusCode == 200 else {
            print("Can't download \(downloadUrl)")
            return // no need to save other http responses
        }
        
        try save(data: data, to: cacheUrl)
    }
    
    func hasFile(at cacheUrl: URL) -> Bool {
        fileManager.fileExists(atPath: cacheUrl.path)
    }
    
    private let fileManager = FileManager.default
    
    func save(data: Data, to file: URL) throws {
        print("Will write to \(file)")
        
        let folderPath = file.deletingLastPathComponent()
        
        try fileManager.createDirectory(
            at: folderPath,
            withIntermediateDirectories: true)
        
        try data.write(to: file)
    }
}

public struct SamplesStructure: Codable, Equatable {
    public let languages: [String:[Project]]
}

public struct Project: Codable, Equatable {
    public let name: String
    public let documents: [DocumentPath]
}

public struct DocumentPath: Equatable {
    public let relativePath: String
    public let name: String
    public let files: [String]
    /// In kilobytes
    public let fileSize: Int
    public let version: Int
}

extension DocumentPath: Codable {}
