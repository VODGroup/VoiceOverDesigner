import Foundation

public class SamplesLoader {
    
    public init() {}
    
    public func loadStructure() async throws -> SamplesStructure {
        let (data, _) = try await URLSession.shared
            .data(from: ProjectPath.structurePath())
        
        let structure = try JSONDecoder()
            .decode(SamplesStructure.self, from: data)
        
        return structure
    }
}

public class SampleLoader {

    private let document: DocumentPath
    private let projectPath: ProjectPath
    
    public init(document: DocumentPath) {
        self.document = document
        self.projectPath = ProjectPath(document: document)
    }
    
    var documentPathInCache: URL {
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
    
    func isFullyLoaded() -> Bool {
        for file in document.files {
            let saveUrl = documentPathInCache.appendingPathComponent(file)
            let isExists = fileManager.fileExists(atPath: saveUrl.path)
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
            let downloadUrl = documentURL.appendingPathComponent(file)
            let saveUrl = resultDocumentPath.appendingPathComponent(file)
            
            if fileManager.fileExists(atPath: saveUrl.path) {
                print("File \(saveUrl) is exists, skip loading")
                continue
            }
            
            let (data, _) = try await URLSession.shared.data(from: downloadUrl)
            
            try save(data: data, to: saveUrl)
        }
    }
    
    private let fileManager = FileManager.default
    private func save(data: Data, to file: URL) throws {
        print("Will write to \(file)")
        
        let folderPath = file.deletingLastPathComponent()
        
        try fileManager.createDirectory(
            at: folderPath,
            withIntermediateDirectories: true)
        
        try data.write(to: file)
    }
}

public struct SamplesStructure: Codable, Equatable {
    public let languages: [String:[DocumentPath]]
}

public struct DocumentPath: Equatable {
    public let relativePath: String
    public let documentName: String
    public let files: [String]
}

extension DocumentPath: Codable {}
