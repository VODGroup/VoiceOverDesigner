import Foundation

public class SampleLoader {

    public init() {}
    
    public func download(document: DocumentPath) async throws {
        let projectPath = ProjectPath(document: document)
        
        try await download(files: document.files,
                           documentURL: projectPath.documentBaseURL(),
                           saveTo: projectPath.cachaPath())
    }
    
    private func download(
        files: [String],
        documentURL: URL,
        saveTo resultDocumentPath: URL
    ) async throws {
        for file in files {
            let downloadUrl = documentURL.appendingPathComponent(file)
            let saveUrl = resultDocumentPath.appendingPathComponent(file)
            
            let (data, _) = try await URLSession.shared.data(from: downloadUrl)
            
            try save(data: data, to: saveUrl)
        }
    }
    
    private let fileManager = FileManager.default
    private func save(data: Data, to file: URL) throws {
        print("Will write to \(file)")
        
        try fileManager.createDirectory(
            at: file.deletingLastPathComponent(),
            withIntermediateDirectories: true)
        try data.write(to: file)
    }
}

public struct SampleDto {
    let documents: [DocumentPath]
}

public struct DocumentPath {
    public init(relativePath: String, documentName: String, files: [String]) {
        self.relativePath = relativePath
        self.documentName = documentName
        self.files = files
    }
    
    let relativePath: String
    let documentName: String
    let files: [String]
}
